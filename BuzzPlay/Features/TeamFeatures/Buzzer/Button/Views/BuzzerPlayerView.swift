//
//  BuzzerPlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    var gameType: GameType
    var body: some View {
        ZStack {
            if let buzzerVM = teamGameVM.currentBuzzerVM {
                VStack {
                    PublicDisplayView(teamGameVM: teamGameVM, gameType: gameType)

                    Spacer()

                    BuzzerButtonView(buzzerVM: buzzerVM)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    BackgroundAppView()
                )
            } else {
                Text("Pas de buzzer BUG DE OUF")
            }

            if !teamGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: teamGameVM.isConnectedToMaster)
    }
}

#Preview {
    BuzzerPlayerView(teamGameVM: TeamGameViewModel(team: sampleTeams[0], mpc: MPCService(peerName: "Team1", role: .team)), gameType: .blindTest)
}
