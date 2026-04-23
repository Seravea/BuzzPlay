//
//  BuzzerPlayerView.swift
//  BuzzPlay
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    var gameType: GameType
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            if let buzzerVM = teamGameVM.currentBuzzerVM {
                if sizeClass == .regular {
                    ipadLayout(buzzerVM: buzzerVM)
                } else {
                    iphoneLayout(buzzerVM: buzzerVM)
                }
            }

            if !teamGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
                    .transition(.opacity)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: teamGameVM.isConnectedToMaster)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Retour")
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - iPhone Layout

    private func iphoneLayout(buzzerVM: BuzzerViewModel) -> some View {
        VStack(spacing: 0) {
            PublicDisplayView(teamGameVM: teamGameVM, gameType: gameType)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .frame(maxHeight: 320)

            Spacer()

            BuzzerButtonView(buzzerVM: buzzerVM)
                .padding(.bottom, 36)
        }
    }

    // MARK: - iPad Layout

    private func ipadLayout(buzzerVM: BuzzerViewModel) -> some View {
        HStack(spacing: 0) {
            PublicDisplayView(teamGameVM: teamGameVM, gameType: gameType)
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
        teamGameVM: TeamGameViewModel(
            team: sampleTeams[0],
            mpc: MPCService(peerName: "Team1", role: .team)
        ),
        gameType: .blindTest
    )
}
