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
    @Bindable var teamFlowVM: TeamFlowViewModel
    var body: some View {
            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(GameType.allCases, id: \.self) { game in
                            ButtonChooseGameView(isOpen: teamGameVM.gameIsAvalaible(game), action: {
                                teamGameVM.currentBuzzerVM = teamFlowVM.makeBuzzerViewModel(for: game == .quiz ? .quiz : .blindTest)
                                router.push(game.destinationPlayer)
                            }, title: game.gameTitle, iconName: game.iconName)
                            .frame(minWidth: 200)
                        }
                    }
                    .padding(.leading, 8)
                }
                .scrollIndicators(.hidden)
                Spacer()
            }
            .background(
                BackgroundAppView()
            )
            .navigationBarBackButtonHidden()
        
    }
}

#Preview {
    PlayerChooseGameView(teamGameVM: TeamGameViewModel(team: Team(name: "la team", teamColor: .blueGame), mpc: MPCService(peerName: "l'équipe", role: .team), clientMode: .team), teamFlowVM: TeamFlowViewModel())
}
