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
            }

            if !playerGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
                    .transition(.opacity)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    BuzzerPlayerView(
        playerGameVM: PlayerGameViewModel(
            player: samplePlayers[0],
            mpc: MPCService(peerName: "Team1", role: .team)
        ),
        gameType: .blindTest
    )
}
