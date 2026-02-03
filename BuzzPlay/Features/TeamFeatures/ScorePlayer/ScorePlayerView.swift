//
//  ScorePlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 09/01/2026.
//

import SwiftUI

struct ScorePlayerView: View {
    var teamGameVM: TeamGameViewModel
    var body: some View {
        VStack {
          
            TeamCardView(team: teamGameVM.team, showPoints: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    BackgroundAppView()
                )
        }
    }
}

#Preview {
    ScorePlayerView(teamGameVM: TeamGameViewModel(team: sampleTeams[0], mpc: MPCService(peerName: sampleTeams[0].name, role: .team), clientMode: .team))
}
