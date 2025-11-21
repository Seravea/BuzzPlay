//
//  PlayerChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct PlayerChooseGameView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                   Spacer()
                    
                    ForEach(GameType.allCases, id: \.self) { game in
                        ButtonChooseGameView(isOpen: teamGameVM.gameIsAvalaible(game), geo: geo, action: {
                            router.push(game.destinationPlayer)
                        }, title: game.gameTitle)
                        
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
    PlayerChooseGameView(teamGameVM: TeamGameViewModel(team: Team(name: "la team", teamColor: .blueGame), mpc: MPCService(peerName: "l'équipe", role: .team), clientMode: .team))
}
