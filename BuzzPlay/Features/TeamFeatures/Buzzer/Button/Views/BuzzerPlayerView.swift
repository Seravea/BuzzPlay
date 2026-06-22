//
//  BuzzerPlayerView.swift
//  BuzzPlay
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    var gameType: GameType
    @State private var coinsVM: CoinsViewModel
    @State private var isGiftSheetOpen = false
    @Environment(\.scenePhase) private var scenePhase

    init(playerGameVM: PlayerGameViewModel, gameType: GameType) {
        self._playerGameVM = Bindable(playerGameVM)
        self.gameType = gameType
        self._coinsVM = State(initialValue: CoinsViewModel(playerGameVM: playerGameVM))
    }

    // #E3 — vrai si une question Quiz est actuellement révélée (utilisé pour le countdown de reprise)
    private var isQuizQuestionRevealed: Bool {
        if case .quiz(let state) = playerGameVM.publicState { return state.isQuestionRevealed }
        return false
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            if let buzzerVM = playerGameVM.currentBuzzerVM {
                iphoneLayout(buzzerVM: buzzerVM)

                if let result = buzzerVM.answerResult {
                    AnswerFeedbackOverlay(result: result)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                        .zIndex(100)
                }

                // #E3 — overlay plein écran uniquement au démarrage de manche (question pas encore révélée).
                // Au refus (question déjà révélée), le décompte s'affiche discrètement sous le buzzer.
                if buzzerVM.countdownPhase != .hidden && buzzerVM.answerResult == nil && !isQuizQuestionRevealed {
                    CountdownOverlay(phase: buzzerVM.countdownPhase)
                        .transition(.opacity)
                        .zIndex(99)
                }
            }

            if let hint = playerGameVM.currentBuzzerVM?.activeHint {
                HintBadgeView(hint: hint)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(50)
            }

            // S2 — toast feedback blocage/bouclier
            if let powerFeedback = playerGameVM.currentBuzzerVM?.powerFeedback {
                PowerFeedbackToast(feedback: powerFeedback)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(60)
            }

            if !playerGameVM.isConnectedToMaster {
                if playerGameVM.hasEverConnectedToMaster {
                    ConnectionLostOverlay()
                        .transition(.opacity)
                } else {
                    WaitingForMasterOverlay(phase: playerGameVM.connectionPhase)
                        .transition(.opacity)
                }
            }

            if playerGameVM.showNewGameNotification {
                NewGameNotificationOverlay()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .zIndex(200)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: playerGameVM.showNewGameNotification)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: playerGameVM.currentBuzzerVM?.answerResult != nil)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: playerGameVM.currentBuzzerVM?.activeHint)
        .animation(.buzzSmooth, value: playerGameVM.currentBuzzerVM?.powerFeedback)
        .animation(.buzzEase, value: playerGameVM.isConnectedToMaster)
        // #15 — classement inter-manche en demi-sheet : la révélation de la réponse reste
        // visible en haut (PublicDisplayView), le classement animé monte par-dessous.
        .sheet(isPresented: $playerGameVM.showPostRoundLeaderboard) {
            PostRoundLeaderboardView(
                previousRanking: playerGameVM.previousRanking,
                currentRanking: playerGameVM.knownPlayers
            )
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.sheetBg)
            .interactiveDismissDisabled()
        }
        .navigationBarBackButtonHidden()
        // #D11/#C3 — empêcher la mise en veille pendant la partie (cause de déconnexion MPC)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .overlay(alignment: .top) {
            // #v1-economy — toast piloté par le wallet local (gains quotidiens / fin de partie)
            if let notes = playerGameVM.notesWallet.pendingCreditToast {
                NotesToastView(amount: notes)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameRhythm.notesToast) {
                            withAnimation(.buzzSlide) {
                                playerGameVM.notesWallet.pendingCreditToast = nil
                            }
                        }
                    }
            }
        }
        .animation(.buzzSmooth, value: playerGameVM.notesWallet.pendingCreditToast != nil)
        .task {
            // Délai pour laisser la transition de navigation se terminer
            // avant d'envoyer playerReady (#A5)
            try? await Task.sleep(for: GameRhythm.playerReadyFirst)
            playerGameVM.syncBuzzerWithCurrentPublicState()
            playerGameVM.sendPlayerReady()
        }
        // #v1-economy — le shop se débloque à la confirmation du Master (buyGiftResult),
        // plus de sync de solde via MPC (le solde vit en local).
        .onChange(of: playerGameVM.giftConfirmationCount) { _, _ in
            coinsVM.onGiftConfirmed()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background, .inactive:
                playerGameVM.handleSceneDidBackground()
            case .active:
                playerGameVM.handleSceneWillForeground()
            @unknown default:
                break
            }
        }
        .sheet(isPresented: $isGiftSheetOpen) {
            GiftShopSheet(coinsVM: coinsVM, isPresented: $isGiftSheetOpen)
                .presentationDetents([.fraction(0.90)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
        }
    }

    // MARK: - iPhone Layout

    private func iphoneLayout(buzzerVM: BuzzerViewModel) -> some View {
        VStack(spacing: 0) {
            compactHeader(buzzerVM: buzzerVM)

            // #14/#17/#D5 — zone de contenu à hauteur réservée = UN SEUL élément greedy.
            // Avant : ce conteneur ET un Spacer() étaient tous deux maxHeight:.infinity → ils se
            // battaient pour l'espace et le partage 50/50 se recalculait à chaque changement de
            // contenu (question révélée, buzz), faisant bouger le buzzer et pousser le header.
            // Le contenu variable (question/titre/buzz) bouge maintenant À L'INTÉRIEUR de cette
            // zone fixe, top-aligné : le buzzer reste ancré et le header reste figé en haut.
            PublicDisplayView(playerGameVM: playerGameVM, gameType: gameType)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.top, BuzzSpacing.md)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            BuzzerButtonView(buzzerVM: buzzerVM, showInlineCountdown: isQuizQuestionRevealed)
                .padding(.bottom, BuzzSpacing.xl)

            GiftBottomBar(coinsVM: coinsVM, isSheetOpen: $isGiftSheetOpen, isWaiting: playerGameVM.publicState == .waiting)
                .padding(.bottom, BuzzSpacing.xxl)
        }
    }

    private func compactHeader(buzzerVM: BuzzerViewModel) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            Text(gameType.gameTitle)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            // Bouclier actif
            let hasAnyShield = playerGameVM.player.hasShieldSingle || playerGameVM.player.hasShieldAll
            if hasAnyShield {
                let shieldIcon = playerGameVM.player.hasShieldAll ? "shield.lefthalf.filled" : "shield.fill"
                let shieldLabel = playerGameVM.player.hasShieldAll ? "×Tous" : "×1"
                Text("\(Image(systemName: shieldIcon)) \(shieldLabel)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.blueLeading)
                    .pillStyle(fill: Color.blueLeading.opacity(0.18),
                               stroke: Color.blueLeading.opacity(0.4),
                               compact: true)
                    .transition(.scale.combined(with: .opacity))
            }

            // Bouton mute son buzzer
            Button {
                withAnimation(.buzzSnappy) {
                    buzzerVM.isBuzzMuted.toggle()
                }
            } label: {
                Image(systemName: buzzerVM.isBuzzMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .textStyle(Typography.cardTitle)
                    .foregroundStyle(buzzerVM.isBuzzMuted ? Color.textDim : .white.opacity(0.85))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(buzzerVM.isBuzzMuted ? "Activer le son du buzzer" : "Couper le son du buzzer")
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, BuzzSpacing.sm)
        .background(Color.black.opacity(0.25))
    }

}

// MARK: - Hint Badge (gift showIndicies)

private struct HintBadgeView: View {
    let hint: String

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.mustardYellow)
                Text(hint)
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Notes Toast

private struct NotesToastView: View {
    let amount: Int

    var body: some View {
        // .firstTextBaseline — garde l'accent coloré de l'icône tout en l'alignant sur la
        // ligne de base du texte (Nohemi calée haut → un .center la ferait paraître basse).
        HStack(alignment: .firstTextBaseline, spacing: BuzzSpacing.sm) {
            Image(systemName: "dollarsign.bank.building.fill")
                .textStyle(Typography.labelSMBold)
                .foregroundStyle(Color.mustardYellow)
            Text("+\(amount) Notes reçues !")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.vertical, BuzzSpacing.md)
        .background(Color.darkPurple, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1.5))
        .shadow(color: Color.mustardYellow.opacity(0.25), radius: 12, y: 4)
        .padding(.top, BuzzSpacing.sm)
    }
}

// MARK: - Power Feedback Toast (S2 — blocage / bouclier)

private struct PowerFeedbackToast: View {
    let feedback: PowerFeedback

    private var color: Color {
        switch feedback.tone {
        case .offense: Color.redLeading
        case .shield:  Color.blueLeading
        }
    }

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: BuzzSpacing.sm) {
                Image(systemName: feedback.symbol)
                    .textStyle(Typography.labelSMBold)
                    .foregroundStyle(color)
                Text(feedback.text)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.vertical, BuzzSpacing.md)
            .background(Color.darkPurple, in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.45), lineWidth: 1.5))
            .shadow(color: color.opacity(0.25), radius: 12, y: 4)
            .padding(.top, BuzzSpacing.sm)
            Spacer()
        }
    }
}

// MARK: - Answer Feedback Overlay (#B5 — Neon Gradient Blast)

private struct AnswerFeedbackOverlay: View {
    let result: AnswerResult

    @State private var glowPulse = false

    private var gradientColors: [Color] {
        switch result {
        case .correct:      [Color.greenButtonLeading, Color.greenTrailing]
        case .incorrect:    [Color.redLeading, Color.purpleTrailing]
        case .otherCorrect: [Color.yellowLeading, Color.yellowTrailing]
        }
    }

    private var label: String {
        switch result {
        case .correct:      "BONNE RÉPONSE"
        case .incorrect:    "MAUVAISE RÉPONSE"
        case .otherCorrect: ""
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Gradient card
                VStack(spacing: 18) {
                    switch result {
                    case .correct(let points, let answer):
                        Text(label)
                            .font(.custom("Nohemi-Black", size: 28))
                            .tracking(4)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 20))
                                .foregroundStyle(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                        }

                        // Score badge
                        Text("+\(points) POINT\(points > 1 ? "S" : "")")
                            .font(.custom("Nohemi-Black", size: 22))
                            .tracking(2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BuzzSpacing.xl)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.30), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.textDim, lineWidth: 1))

                    case .incorrect:
                        Text(label)
                            .font(.custom("Nohemi-Black", size: 28))
                            .tracking(4)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                    case .otherCorrect(let name, let points, let answer):
                        Text("\(name) A TROUVÉ !")
                            .font(.custom("Nohemi-Black", size: 26))
                            .tracking(3)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 19))
                                .foregroundStyle(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                        }

                        Text("+\(points) PT\(points > 1 ? "S" : "") POUR \(name.uppercased())")
                            .font(.custom("Nohemi-Black", size: 16))
                            .tracking(2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BuzzSpacing.xl)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.30), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.textDim, lineWidth: 1))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .padding(.horizontal, BuzzSpacing.xxxl)
                .background(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                )
                .shadow(color: gradientColors[0].opacity(glowPulse ? 0.55 : 0.25), radius: glowPulse ? 32 : 14)
            }
            .padding(.horizontal, BuzzSpacing.xxxl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - New Game Notification Overlay (#B6)

private struct NewGameNotificationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.60).ignoresSafeArea()

            VStack(spacing: BuzzSpacing.lg) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.purpleLeading)

                VStack(spacing: 6) {
                    Text("Nouvelle partie !")
                        .font(.custom("Nohemi-Black", size: 26))
                        .tracking(1)
                        .foregroundStyle(.white)
                    Text("Le Master relance une partie")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.60))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                    .fill(.ultraThinMaterial.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                        .strokeBorder(Color.purpleLeading.opacity(0.35), lineWidth: 1.5))
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    let samplePlayer = Player(name: "Team 1", teamColor: .greenGame, score: 240)
    return BuzzerPlayerView(
        playerGameVM: PlayerGameViewModel(
            player: samplePlayer,
            mpc: MPCService(peerName: "Team1", role: .team)
        ),
        gameType: .blindTest
    )
}
