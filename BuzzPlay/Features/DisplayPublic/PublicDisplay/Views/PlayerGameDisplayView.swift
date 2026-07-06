//
//  PlayerGameDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PlayerGameDisplayView: View {
    
    @Bindable var playerGameVM: PlayerGameViewModel
    var gameType: GameType  
    var body: some View {
        VStack {
            switch playerGameVM.publicState {
            case .waiting:
                VStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "hourglass")
                        .textStyle(Typography.screenTitleSoft)
                        .foregroundStyle(Color.textMuted)
                    Text("En attente du lancement…")
                        .font(.nohemi(.title3, weight: .bold)).titleTracking()
                        .foregroundStyle(.white)
                    Text("Le Maître va démarrer la partie")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(Color.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.xxl)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg2).strokeBorder(.white.opacity(0.08), lineWidth: 1))

                case .quiz(let quizState):
                    PlayerQuizDisplayView(state: quizState, timer: playerGameVM.formattedTime, timerReady: playerGameVM.hasReceivedFirstTimer)
                    
                case .blindTest(let blindTestState):
                PlayerBlindTestDisplayView(state: blindTestState, timer: playerGameVM.formattedTime)
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
    return PlayerGameDisplayView(playerGameVM: vm, gameType: .blindTest)
}

