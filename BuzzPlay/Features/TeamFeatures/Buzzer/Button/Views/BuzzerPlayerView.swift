//
//  BuzzerPlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    
    var body: some View {
        if let buzzerVM = teamGameVM.currentBuzzerVM {
            if teamGameVM.isPublicDisplayActive {
                VStack {
                    //PublicView
                    
                    BuzzerButtonView(buzzerVM: buzzerVM)
                }
            } else {
                BuzzerButtonView(buzzerVM: buzzerVM)
            }
        } else {
            Text("Pas de buzzer BUG DE OUF")
        }
    }
}

#Preview {
    BuzzerPlayerView(teamGameVM: TeamGameViewModel(team: sampleTeams[0], mpc: MPCService(peerName: "Team1", role: .team), clientMode: .team))
}
