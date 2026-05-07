//
//  BuzzerPlayerView.swift
//  BuzzPlay
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    var gameType: GameType
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            if let buzzerVM = playerGameVM.currentBuzzerVM {
                if sizeClass == .regular {
                    ipadLayout(buzzerVM: buzzerVM)
                } else {
                    iphoneLayout(buzzerVM: buzzerVM)
                }

                if let result = buzzerVM.answerResult {
                    AnswerFeedbackOverlay(result: result)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                        .zIndex(100)
                }
            }

            if !playerGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
                    .transition(.opacity)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: playerGameVM.currentBuzzerVM?.answerResult != nil)
        .animation(.easeInOut(duration: 0.3), value: playerGameVM.isConnectedToMaster)
        .navigationBarBackButtonHidden()
    }

    // MARK: - iPhone Layout

    private func iphoneLayout(buzzerVM: BuzzerViewModel) -> some View {
        VStack(spacing: 0) {
            compactHeader

            PublicDisplayView(playerGameVM: playerGameVM, gameType: gameType)
                .padding(.horizontal, 12)
                .padding(.top, 12)

            Spacer()

            BuzzerButtonView(buzzerVM: buzzerVM)
                .padding(.bottom, 36)
        }
    }

    private var compactHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let title = playerGameVM.publicState.displayTitle {
                    Text(title)
                        .font(.nohemi(.caption, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                if let subtitle = playerGameVM.publicState.displaySubtitle {
                    Text(subtitle)
                        .font(.nohemi(.caption2, weight: .regular))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .opacity(0.6)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("TEMPS")
                    .font(.nohemi(.caption2, weight: .thin))
                    .tracking(0.5)
                    .opacity(0.5)
                Text(playerGameVM.formattedTime)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.25))
    }

    // MARK: - iPad Layout

    private func ipadLayout(buzzerVM: BuzzerViewModel) -> some View {
        HStack(spacing: 0) {
            PublicDisplayView(playerGameVM: playerGameVM, gameType: gameType)
                .padding(36)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white.opacity(0.03))

            VStack {
                Spacer()
                BuzzerButtonView(buzzerVM: buzzerVM)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(36)
        }
    }
}

// MARK: - Answer Feedback Overlay

private struct AnswerFeedbackOverlay: View {
    let result: AnswerResult

    private var isCorrect: Bool {
        if case .correct = result { return true }
        return false
    }

    private var accentColor: Color { isCorrect ? Color(hex: "#00C875") : Color(hex: "#FF4D4D") }
    private var iconName: String { isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill" }
    private var label: String { isCorrect ? "BONNE RÉPONSE" : "MAUVAISE RÉPONSE" }

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
                    Text(label)
                        .font(.custom("Nohemi-Black", size: 30))
                        .tracking(2)
                        .foregroundStyle(.white)

                    if case .correct(let points, let answer) = result {
                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 22))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        Text("+\(points) point\(points > 1 ? "s" : "")")
                            .font(.custom("Nohemi-Black", size: 26))
                            .foregroundStyle(accentColor)
                    } else {
                        Text("+0 point")
                            .font(.custom("Nohemi-SemiBold", size: 22))
                            .foregroundStyle(.white.opacity(0.5))
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
    BuzzerPlayerView(
        playerGameVM: PlayerGameViewModel(
            player: samplePlayers[0],
            mpc: MPCService(peerName: "Team1", role: .team)
        ),
        gameType: .blindTest
    )
}
