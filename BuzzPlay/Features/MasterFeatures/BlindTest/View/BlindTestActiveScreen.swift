//
//  BlindTestActiveScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestActiveScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onValidate: (Int) -> Void
    let onReject: () -> Void
    let onSkip: () -> Void
    let onNext: () -> Void
    // #chantier6 — abandonner la file en cours et revenir composer d'autres titres.
    let onQuitQueue: () -> Void

    var buzzedPlayer: Player? { blindTestVM.playerHasBuzz }

    // #bt-queue — manche validée : on reste sur l'écran pour révéler la réponse + bouton suivant.
    private var isFinished: Bool {
        if case .finished = blindTestVM.state { return true }
        return false
    }

    // #chantier6 — position dans la file : « EN COURS · 3/8 » (masqué si file d'un seul titre).
    private var currentSongLabel: String {
        blindTestVM.queueCount > 1
            ? "EN COURS · \(blindTestVM.queueIndex + 1)/\(blindTestVM.queueCount)"
            : "EN COURS"
    }

    // #audio-bt-nudge — rappel « branche une enceinte » au lancement (la musique ne joue que
    // sur l'appareil Master). Pur UI : la sortie audio AirPlay/Bluetooth est gérée au système.
    @State private var showSpeakerNudge = false
    @State private var hasShownSpeakerNudge = false
    @State private var nudgeTask: Task<Void, Never>?

    // #chantier6 — le Maître passait à la musique suivante AVANT que les joueurs aient vu le
    // titre révélé ET l'animation du classement inter-manche. On verrouille « Musique suivante »
    // le temps de tout l'inter-manche + 1s (GameRhythm.blindTestNextHold). Réarmé par song.
    @State private var nextEnabled = false
    @State private var nextCountdown = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 12) {
                timerHero
                BlindTestQueueStrip(queue: blindTestVM.songQueue, currentIndex: blindTestVM.queueIndex)
                    .padding(.top, BuzzSpacing.md)   // air entre le bandeau chrono et « À venir »
                SolarSystemStageView(
                    song: blindTestVM.selectedMusic,
                    isPlaying: blindTestVM.isPlaying,
                    players: blindTestVM.gameVM.players,
                    buzzedPlayer: buzzedPlayer
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Morceau en cours : carte musique (sans poster) à la place de l'ancienne pilule.
                // #chantier6 — compteur de titres : « EN COURS · 3/8 » quand la file a plusieurs titres.
                BlindTestSongCard(song: blindTestVM.selectedMusic, topLabel: currentSongLabel,
                                  showWaveform: blindTestVM.isPlaying)

                // Hauteur réservée en PERMANENCE (on joue sur l'opacité, pas la présence) → le pied qui
                // apparaît/disparaît ne fait plus reflower la scène : le soleil ne se déplace plus au buzz.
                let showWaiting = blindTestVM.isPlaying && buzzedPlayer == nil && !isFinished
                waitingFooter
                    .opacity(showWaiting ? 1 : 0)
                    .allowsHitTesting(showWaiting)
                    .animation(.buzzFade, value: showWaiting)
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.top, BuzzSpacing.sm)

            // Buzz : pas de voile plein écran → le soleil + la planète qui brille restent visibles.
            // La sheet de validation remonte en mode compact (la planète illuminée dit déjà qui a buzzé).
            if let player = buzzedPlayer, !isFinished {
                BlindTestBuzzSheet(
                    player: player,
                    reactionTime: blindTestVM.formattedTime,
                    buzzStartedAt: blindTestVM.buzzStartedAt,
                    compact: true,
                    song: blindTestVM.selectedMusic,
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }

            // #bt-queue — manche validée : révélation + bouton « Musique suivante ».
            // Masqué si le quota fini est atteint (shouldAutoFinish → l'overlay de section prend le relais)
            // ou pendant une révélation auto de morceau passé (#chantier6 — pas de bouton, on enchaîne seul).
            if isFinished && !blindTestVM.shouldAutoFinish && !blindTestVM.isAutoRevealing {
                finishedPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(120)
                    // #chantier6 — verrou anti-avance-trop-rapide, réarmé à chaque morceau.
                    .task(id: blindTestVM.queueIndex) {
                        nextEnabled = false
                        // Décompte 1s par 1s (arrondi au sup.) → le Maître voit le verrou fondre.
                        let c = GameRhythm.blindTestNextHold.components
                        let total = Int(c.seconds) + (c.attoseconds > 0 ? 1 : 0)
                        for remaining in stride(from: total, through: 1, by: -1) {
                            nextCountdown = remaining
                            try? await Task.sleep(for: .seconds(1))
                            if Task.isCancelled { return }
                        }
                        nextEnabled = true
                    }
            }

            if blindTestVM.roundCountdownPhase != .hidden {
                CountdownOverlay(phase: blindTestVM.roundCountdownPhase, label: "Prochain buzz dans", backgroundOpacity: 0.30)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.05), value: buzzedPlayer != nil)
        .animation(.spring(duration: 0.4, bounce: 0.05), value: isFinished)
        .animation(.buzzFade, value: blindTestVM.roundCountdownPhase)
        .overlay(alignment: .top) {
            if showSpeakerNudge {
                speakerNudge
                    .padding(.top, BuzzSpacing.sm)
                    .padding(.horizontal, BuzzSpacing.xl)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(150)
            }
        }
        // #D11/#C3 — empêcher la veille iPhone pendant la partie
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            showSpeakerNudgeOnce()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            nudgeTask?.cancel()
        }
    }

    // MARK: - Panneau fin de manche (#bt-queue)

    private var finishedPanel: some View {
        VStack(spacing: BuzzSpacing.md) {
            if let winner = blindTestVM.playerHasBuzz {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .textStyle(Typography.cardTitle)
                        .foregroundStyle(Color.greenGlow)
                    Text("\(winner.name) a trouvé")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                }
            } else {
                Text("Manche terminée")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
            }

            Button(action: onNext) {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: nextEnabled
                          ? (blindTestVM.hasNextInQueue ? "forward.fill" : "music.note.list")
                          : "hourglass")
                        .textStyle(Typography.labelSM)
                    Text(!nextEnabled
                         ? "Résultats aux joueurs… \(nextCountdown)"
                         : blindTestVM.hasNextInQueue
                            ? "Musique suivante (\(blindTestVM.queueIndex + 2)/\(blindTestVM.queueCount))"
                            : "Choisir d'autres titres")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.lg)
                .background(
                    LinearGradient(colors: nextEnabled ? [.purpleLeading, .purpleTrailing]
                                                        : [.white.opacity(0.10), .white.opacity(0.08)],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                )
                .shadow(color: nextEnabled ? Color.purpleLeading.opacity(0.35) : .clear, radius: 8)
            }
            .buttonStyle(.plain)
            .disabled(!nextEnabled)
            .animation(.buzzDefault, value: nextEnabled)

            // #chantier6 — sortie de file : quand il reste des titres, on n'est plus
            // obligé d'aller au bout — « Changer de titres » ramène à la composition.
            // (File épuisée : le bouton principal EST déjà « Choisir d'autres titres ».)
            if blindTestVM.hasNextInQueue {
                Button(action: onQuitQueue) {
                    Text("Changer de titres \(Image(systemName: "music.note.list"))")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(Color.textSoft)
                        .pillStyle(fill: .white.opacity(0.08),
                                   stroke: .white.opacity(0.12),
                                   compact: true,
                                   trailingIcon: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(.white.opacity(0.1), lineWidth: 1))
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.bottom, BuzzSpacing.xl)
    }

    // MARK: - Nudge enceinte (#audio-bt-nudge)

    private var speakerNudge: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "airplayaudio")
                .font(.footnote)
                .foregroundStyle(Color.mustardYellow)
            Text("Branche une enceinte ou AirPlay pour l'ambiance")
                .font(.nohemi(.caption, weight: .semiBold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: BuzzSpacing.sm)
            Image(systemName: "xmark")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.sm)
        .glassCardMedium(radius: BuzzRadius.lg)
        .contentShape(Rectangle())
        .onTapGesture { dismissSpeakerNudge() }
    }

    // Affiche le nudge une seule fois par lancement de partie, auto-dismiss après 6s.
    private func showSpeakerNudgeOnce() {
        guard !hasShownSpeakerNudge else { return }
        hasShownSpeakerNudge = true
        withAnimation(.buzzFade) { showSpeakerNudge = true }
        nudgeTask?.cancel()
        nudgeTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            withAnimation(.buzzFade) { showSpeakerNudge = false }
        }
    }

    private func dismissSpeakerNudge() {
        nudgeTask?.cancel()
        withAnimation(.buzzFade) { showSpeakerNudge = false }
    }

    private var timerHero: some View {
        HStack {
            Text(blindTestVM.formattedTime)
                .font(.nohemi(.largeTitle, weight: .extraBold)).titleTracking()
                .foregroundStyle(buzzedPlayer != nil ? Color.purpleTrailing : .mustardYellow)
                .tracking(3)
                .monospacedDigit()   // largeur de chiffre fixe → le chrono ne tremble pas
                .nohemiBadgeNudge(fontSize: 34)   // Nohemi sied haut → recentre le chrono dans la card
                // pas de contentTransition/animation : mise à jour sans roulement, 0 mouvement
            Spacer()
            Text(buzzedPlayer != nil ? "PAUSÉ" : (blindTestVM.isPlaying ? "EN COURS" : "TERMINÉ"))
                .font(.nohemi(.caption, weight: .bold))
                .tracking(0.5)   // majuscules : respirent mieux
                .foregroundStyle(.white.opacity(0.6))
                .pillStyle(fill: .white.opacity(0.08), stroke: nil, compact: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
    }

    // Pied de scène : radar « en attente » + bouton Passer (le classement vit désormais sur les planètes).
    private var waitingFooter: some View {
        HStack {
            HStack(spacing: 10) {
                RadarPulseView()
                Text("En attente d'un buzz…")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }
            Spacer()
            Button(action: onSkip) {
                // Symbole interpolé dans le Text → aligné sur la ligne de base.
                Text("Passer \(Image(systemName: "forward.end.fill"))")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(Color.textSoft)
                    .pillStyle(fill: .white.opacity(0.08),
                               stroke: .white.opacity(0.12),
                               compact: true,
                               trailingIcon: true)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, BuzzSpacing.sm)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestActiveScreen(
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()),
            onValidate: { _ in },
            onReject: {},
            onSkip: {},
            onNext: {},
            onQuitQueue: {}
        )
    }
}
