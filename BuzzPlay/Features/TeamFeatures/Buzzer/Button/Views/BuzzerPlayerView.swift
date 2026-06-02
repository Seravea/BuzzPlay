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

                if buzzerVM.countdownPhase != .hidden {
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

            if playerGameVM.showPostRoundLeaderboard {
                PostRoundLeaderboardView(
                    previousRanking: playerGameVM.previousRanking,
                    currentRanking: playerGameVM.knownPlayers
                )
                .transition(.opacity)
                .zIndex(80)
            }

            if !playerGameVM.isConnectedToMaster {
                if playerGameVM.hasEverConnectedToMaster {
                    ConnectionLostOverlay()
                        .transition(.opacity)
                } else {
                    WaitingForMasterOverlay()
                        .transition(.opacity)
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: playerGameVM.currentBuzzerVM?.answerResult != nil)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: playerGameVM.currentBuzzerVM?.activeHint)
        .animation(.easeInOut(duration: 0.3), value: playerGameVM.isConnectedToMaster)
        .animation(.easeInOut(duration: 0.35), value: playerGameVM.showPostRoundLeaderboard)
        .navigationBarBackButtonHidden()
        .overlay(alignment: .top) {
            if let notes = playerGameVM.pendingNotesToast {
                NotesToastView(amount: notes)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                playerGameVM.pendingNotesToast = nil
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: playerGameVM.pendingNotesToast != nil)
        .onAppear { playerGameVM.syncBuzzerWithCurrentPublicState() }
        .onChange(of: playerGameVM.player.accountAmount) { _, _ in
            coinsVM.onPlayerUpdated(playerGameVM.player)
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

            PublicDisplayView(playerGameVM: playerGameVM, gameType: gameType)
                .padding(.horizontal, 12)
                .padding(.top, 12)

            Spacer()

            BuzzerButtonView(buzzerVM: buzzerVM)
                .padding(.bottom, 20)

            GiftBottomBar(coinsVM: coinsVM, isSheetOpen: $isGiftSheetOpen, isWaiting: playerGameVM.publicState == .waiting)
                .padding(.bottom, 24)
        }
    }

    private func compactHeader(buzzerVM: BuzzerViewModel) -> some View {
        HStack(spacing: 12) {
            Text(gameType.gameTitle)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            // Bouclier actif
            let hasAnyShield = playerGameVM.player.hasShieldSingle || playerGameVM.player.hasShieldAll
            if hasAnyShield {
                HStack(spacing: 3) {
                    Image(systemName: playerGameVM.player.hasShieldAll ? "shield.lefthalf.filled" : "shield.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text(playerGameVM.player.hasShieldAll ? "×Tous" : "×1")
                        .font(.nohemi(.caption2, weight: .bold))
                }
                .foregroundStyle(Color(hex: "2B7FFF"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "2B7FFF").opacity(0.18), in: Capsule())
                .overlay(Capsule().strokeBorder(Color(hex: "2B7FFF").opacity(0.4), lineWidth: 1))
                .transition(.scale.combined(with: .opacity))
            }

            // Bouton mute son buzzer
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    buzzerVM.isBuzzMuted.toggle()
                }
            } label: {
                Image(systemName: buzzerVM.isBuzzMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(buzzerVM.isBuzzMuted ? .white.opacity(0.35) : .white.opacity(0.85))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(buzzerVM.isBuzzMuted ? "Activer le son du buzzer" : "Couper le son du buzzer")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Notes Toast

private struct NotesToastView: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "dollarsign.bank.building.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.mustardYellow)
            Text("+\(amount) Notes reçues !")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.darkPurple, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1.5))
        .shadow(color: Color.mustardYellow.opacity(0.25), radius: 12, y: 4)
        .padding(.top, 8)
    }
}

// MARK: - Answer Feedback Overlay

private struct AnswerFeedbackOverlay: View {
    let result: AnswerResult

    private var accentColor: Color {
        switch result {
        case .correct:    Color(hex: "#00C875")
        case .incorrect:  Color(hex: "#FF4D4D")
        case .otherCorrect: Color.mustardYellow
        }
    }

    private var iconName: String {
        switch result {
        case .correct:      "checkmark.circle.fill"
        case .incorrect:    "xmark.circle.fill"
        case .otherCorrect: "checkmark.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 130, height: 130)

                    Image(systemName: iconName)
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(accentColor)
                }

                VStack(spacing: 10) {
                    switch result {
                    case .correct(let points, let answer):
                        Text("BONNE RÉPONSE")
                            .font(.custom("Nohemi-Black", size: 30))
                            .tracking(2)
                            .foregroundStyle(.white)
                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 22))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        Text("+\(points) point\(points > 1 ? "s" : "")")
                            .font(.custom("Nohemi-Black", size: 26))
                            .foregroundStyle(accentColor)

                    case .incorrect:
                        Text("MAUVAISE RÉPONSE")
                            .font(.custom("Nohemi-Black", size: 30))
                            .tracking(2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                    case .otherCorrect(let name, let points, let answer):
                        Text("\(name) a trouvé !")
                            .font(.custom("Nohemi-Black", size: 28))
                            .tracking(1)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 20))
                                .foregroundStyle(.white.opacity(0.80))
                                .multilineTextAlignment(.center)
                        }
                        Text("+\(points) pt\(points > 1 ? "s" : "") pour \(name)")
                            .font(.custom("Nohemi-SemiBold", size: 18))
                            .foregroundStyle(accentColor.opacity(0.85))
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .strokeBorder(accentColor.opacity(0.35), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 36)
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
