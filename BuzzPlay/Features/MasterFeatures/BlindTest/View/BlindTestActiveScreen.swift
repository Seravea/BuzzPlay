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
            VStack(spacing: 14) {
                timerHero
                songCard
                scoresSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BuzzSpacing.xl)

            if buzzedPlayer != nil && !isFinished {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .transition(.opacity)
            }

            if let player = buzzedPlayer, !isFinished {
                BlindTestBuzzSheet(
                    player: player,
                    reactionTime: blindTestVM.formattedTime,
                    buzzStartedAt: blindTestVM.buzzStartedAt,
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

    private var songCard: some View {
        HStack(spacing: 14) {
            AsyncImage(url: blindTestVM.selectedMusic?.postertURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundStyle(Color.textSecondary)
                    )
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.xs))

            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text("EN COURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(0.8)
                Text(blindTestVM.selectedMusic?.title ?? "—")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
                Text(blindTestVM.selectedMusic?.artist ?? "—")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            if blindTestVM.isPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .font(.title2)
                    .foregroundStyle(Color.mustardYellow)
            }
        }
        .padding(BuzzSpacing.md)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    private var scoresSection: some View {
        let players = blindTestVM.gameVM.players.sorted { $0.score > $1.score }
        let maxScore = max(players.map(\.score).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("CLASSEMENT EN DIRECT")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(Color.textDim)
                .tracking(0.8)
                .padding(.leading, 2)

            ForEach(players) { player in
                QuizScoreRow(player: player, maxScore: maxScore)
            }

            if blindTestVM.isPlaying && buzzedPlayer == nil {
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
                .padding(.top, 4)
            }
        }
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
