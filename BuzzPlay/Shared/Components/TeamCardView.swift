//
//  TeamCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI


struct TeamCardView: View {
    var player: Player
    var buzzTime: String?
    var isWining: Bool = false
    var showPoints: Bool
    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Text(player.name)


                Spacer()

                if showPoints {
                    Text("\(player.score) pts")

                }
            }
            .font(.nohemi(.title2, weight: .bold))
            
        
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
                            LinearGradient(colors: [Color(player.teamColor.rawValue).opacity(1), Color(player.teamColor.rawValue).opacity(0.7), Color(player.teamColor.rawValue).opacity(0.5),Color(player.teamColor.rawValue).opacity(0.3), Color(player.teamColor.rawValue).opacity(0.2), Color(player.teamColor.rawValue).opacity(0)], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(maxWidth: 100, alignment: .leading)
                    Spacer()
                }
            )
            .shadow(color: Color(player.teamColor.rawValue).opacity(0.2), radius: 12, y: 4)

        }
        .padding()
        
        
    }
}

#Preview {
    let samplePlayer = Player(name: "Team 1", teamColor: .greenGame, score: 240)
    return TeamCardView(player: samplePlayer, showPoints: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
         BackgroundAppView()
        )
}
