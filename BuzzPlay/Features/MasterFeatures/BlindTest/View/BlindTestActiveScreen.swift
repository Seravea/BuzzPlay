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

    var buzzedPlayer: Player? { blindTestVM.playerHasBuzz }

    // #bt-queue — manche validée : on reste sur l'écran pour révéler la réponse + bouton suivant.
    private var isFinished: Bool {
        if case .finished = blindTestVM.state { return true }
        return false
    }

    // #audio-bt-nudge — rappel « branche une enceinte » au lancement (la musique ne joue que
    // sur l'appareil Master). Pur UI : la sortie audio AirPlay/Bluetooth est gérée au système.
    @State private var showSpeakerNudge = false
    @State private var hasShownSpeakerNudge = false
    @State private var nudgeTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 12) {
                timerHero
                BlindTestQueueStrip(queue: blindTestVM.songQueue, currentIndex: blindTestVM.queueIndex)
                SolarSystemStageView(
                    song: blindTestVM.selectedMusic,
                    isPlaying: blindTestVM.isPlaying,
                    players: blindTestVM.gameVM.players,
                    buzzedPlayer: buzzedPlayer
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if blindTestVM.isPlaying && buzzedPlayer == nil && !isFinished {
                    waitingFooter
                }
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
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }

            // #bt-queue — manche validée : révélation + bouton « Musique suivante ».
            // Masqué si le quota fini est atteint (shouldAutoFinish → l'overlay de section prend le relais).
            if isFinished && !blindTestVM.shouldAutoFinish {
                finishedPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(120)
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
                    Image(systemName: blindTestVM.hasNextInQueue ? "forward.fill" : "music.note.list")
                        .textStyle(Typography.labelSM)
                    Text(blindTestVM.hasNextInQueue
                         ? "Musique suivante (\(blindTestVM.queueIndex + 2)/\(blindTestVM.queueCount))"
                         : "Choisir d'autres titres")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.lg)
                .background(
                    LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                )
                .shadow(color: Color.purpleLeading.opacity(0.35), radius: 8)
            }
            .buttonStyle(.plain)
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
            onNext: {}
        )
    }
}
