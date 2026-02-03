//
//  PublicDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicDisplayView: View {
    
    @Bindable var teamGameVM: TeamGameViewModel
    var gameType: GameType  
    var body: some View {
        VStack {
            switch teamGameVM.publicState {
            case .waiting:
                if gameType == .blindTest {
                    Text("Le Master choisi une musique")
                } else if gameType == .quiz {
                    Text("Le Master va envoyer une question")
                }
                Text("Préparez-vous !")

                case .quiz(let quizState):
                    PublicQuizDisplayView(state: quizState, timer: teamGameVM.formattedTime)
                    
                case .blindTest(let blindTestState):
                PublicBlindTestView(state: blindTestState, timer: teamGameVM.formattedTime)
            }
        }
        .onDisappear {
            teamGameVM.publicState = .waiting
        }
    }
}

#Preview {
    // Minimal preview scaffolding
    let vm = TeamGameViewModel(team: Team(name: "Preview Team"),
                               mpc: MPCService(peerName: "Preview", role: .team),
                               clientMode: .team)
    return PublicDisplayView(teamGameVM: vm, gameType: .blindTest)
}

