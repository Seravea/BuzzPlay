//
//  PlayerChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct PlayerChooseGameView: View {
    var teamGameVM: TeamGameViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                   Spacer()
                    ButtonGameCardView(gameTitle: "Blind Test") {
                        router.push(.blindTestPlayer)
                    }
                    
                    ButtonGameCardView(gameTitle: "Quiz") {
                        
                    }
                    
                    ButtonGameCardView(gameTitle: "J'sais Pô") {
                        
                    }

                    Spacer()
                    
                }
                .padding()
                Spacer()
            }
        }
        
    }
}

#Preview {
    PlayerChooseGameView(teamGameVM: TeamGameViewModel(team: Team(name: "la team", colorIndex: 0), mpc: MPCService()))
}
