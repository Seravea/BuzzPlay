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
                VStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                    Text("En attente du lancement…")
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Le Master va démarrer la partie")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))

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
    let vm = TeamGameViewModel(player: Player(name: "Preview Team"),
                               mpc: MPCService(peerName: "Preview", role: .team))
    return PublicDisplayView(teamGameVM: vm, gameType: .blindTest)
}

