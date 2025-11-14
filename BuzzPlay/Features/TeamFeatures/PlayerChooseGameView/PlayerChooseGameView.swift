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
                    
                    ButtonChooseGameView(isOpen: true, geo: geo, action: {
                        router.push(.blindTestPlayer)
                    }, title: GameType.blindTest.gameTitle)
//                    ButtonGameCardView(gameTitle: "Blind Test") {
//                        router.push(.blindTestPlayer)
//                    }
                    
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
    PlayerChooseGameView(teamGameVM: TeamGameViewModel(gameVM: TeamFlowViewModel()))
}
