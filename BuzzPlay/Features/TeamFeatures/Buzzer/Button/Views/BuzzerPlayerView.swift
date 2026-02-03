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
        if let buzzerVM = teamGameVM.currentBuzzerVM {
            if teamGameVM.isPublicDisplayActive {
                // PublicView is ON
                BuzzerButtonView(buzzerVM: buzzerVM)
            } else {
                VStack {
                    PublicDisplayView(teamGameVM: teamGameVM, gameType: gameType)
                    
                    Spacer()
                    
                    BuzzerButtonView(buzzerVM: buzzerVM)
                    // Public display now owns the timer; just pass the VM
                   
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    BackgroundAppView()
                )
            }
        } else {
            Text("Pas de buzzer BUG DE OUF")
        }
    }
}

#Preview {
    BuzzerPlayerView(teamGameVM: TeamGameViewModel(team: sampleTeams[0], mpc: MPCService(peerName: "Team1", role: .team), clientMode: .team), gameType: .blindTest)
}

