//
//  ScoreTeamView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 29/12/2025.
//

import SwiftUI

struct ScoreTeamView: View {
    var teams: [Team]
    var colums: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        
        VStack {
            
            LazyVGrid(columns: colums, spacing: 20) {
                ForEach(teams) { team in
                    TeamCardView(team: team, showPoints: true)
                }
            }
        }
    }
}

#Preview {
    ScoreTeamView(teams: sampleTeams)
}
