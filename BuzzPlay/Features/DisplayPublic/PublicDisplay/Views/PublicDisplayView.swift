//
//  PublicDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicDisplayView: View {
    
    @Bindable var playerGameVM: PlayerGameViewModel
    var gameType: GameType  
    var body: some View {
        VStack {
            switch playerGameVM.publicState {
            case .waiting:
                VStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .textStyle(Typography.screenTitleSoft)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("En attente du lancement…")
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Le Maître va démarrer la partie")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))

                case .quiz(let quizState):
                    PublicQuizDisplayView(state: quizState, timer: playerGameVM.formattedTime, timerReady: playerGameVM.hasReceivedFirstTimer)
                    
                case .blindTest(let blindTestState):
                PublicBlindTestView(state: blindTestState, timer: playerGameVM.formattedTime)
            }
        }
        .onDisappear {
            playerGameVM.publicState = .waiting
        }
    }
}

#Preview {
    // Minimal preview scaffolding
    let vm = PlayerGameViewModel(player: Player(name: "Preview Team"),
                               mpc: MPCService(peerName: "Preview", role: .team))
    return PublicDisplayView(playerGameVM: vm, gameType: .blindTest)
}

