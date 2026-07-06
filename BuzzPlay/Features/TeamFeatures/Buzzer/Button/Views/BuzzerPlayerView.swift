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

    // #answer-window — top du buzz courant (epoch) si quelqu'un a buzzé, pour la barre de 5s.
    private var buzzWindowStart: TimeInterval? {
        switch playerGameVM.publicState {
        case .quiz(let s):      return s.buzzingPlayer != nil ? s.buzzStartedAt : nil
        case .blindTest(let s): return s.buzzingPlayer != nil ? s.buzzStartedAt : nil
        default:                return nil
        }
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
                    WaitingForMasterOverlay(phase: playerGameVM.connectionPhase,
                                            showHelp: playerGameVM.showConnectionHelp,
                                            onRetry: { playerGameVM.retryConnection() })
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

            BuzzerButtonView(buzzerVM: buzzerVM, showInlineCountdown: isQuizQuestionRevealed, buzzStartedAt: buzzWindowStart)
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
