//
//  TeamCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI


struct TeamCardView: View {
    var team: Team
    var buzzTime: String?
    var isWining: Bool = false
    var showPoints: Bool
    var body: some View {
      
        VStack(alignment: .leading) {
            HStack {
                Text(team.name)
                    
                
                Spacer()
                
                if showPoints {
                    Text("\(team.score) pts")
                        
                }
            }
            .font(.nohemi(.title2, weight: .bold))
            
            HStack(spacing: 6) {
                ForEach(team.players) { player in
                    Text(player.name)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .foregroundStyle(.white.opacity(0.5))
                        )
                }
            }
            
        }
        .padding()
        .foregroundStyle(.black)
        .background(
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(
                LinearGradient(colors: [.white.opacity(0), .white.opacity(0.1), .white.opacity(0.1), .white.opacity(0.1), .white.opacity(0.2), .white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
            )
        )
        .padding(.trailing, -8)

        .padding(.leading, 6)
        .background(
            HStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(
                        LinearGradient(colors: [Color(team.teamColor.rawValue).opacity(1), Color(team.teamColor.rawValue).opacity(0.7), Color(team.teamColor.rawValue).opacity(0.5),Color(team.teamColor.rawValue).opacity(0.3), Color(team.teamColor.rawValue).opacity(0.2), Color(team.teamColor.rawValue).opacity(0)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(maxWidth: 100, alignment: .leading)
                Spacer()
            }
        )
        .shadow(color: Color(team.teamColor.rawValue).opacity(0.2), radius: 12, y: 4)

        .padding()
        
        
    }
}

#Preview {
    TeamCardView(team: sampleTeams[0], showPoints: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
         BackgroundAppView()
        )
}
