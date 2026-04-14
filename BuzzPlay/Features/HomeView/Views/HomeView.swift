//
//  TeamChooserView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) private var router
    @State var teamFlowVM = TeamFlowViewModel()
    @State var masterFlowVM = MasterFlowViewModel()

    var body: some View {
        VStack {
            Text("Zik'jeu")
                .font(.nohemi(.largeTitle, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            ScrollView(.horizontal) {
                HStack(spacing: 24) {
                    ForEach(RoleButtonUI.allCases, id: \.self) { role in
                        Button {
                            router.push(role.destination)
                        } label: {
                            ChooseRoleCardsView(roleButtonUI: role)
                                .padding(.leading)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            Spacer()
        }
        .background(BackgroundAppView())
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .homeView:
                HomeView()
            case .masterChooseGameView:
                MasterChooseGameView(masterChooseGameVM: masterFlowVM.makeChooseGameVM())
            case .masterLobbyView:
                LobbyMasterView(masterGameVM: masterFlowVM.makeLobbyViewModel())
            case .playerChooseGameView:
                if let vm = teamFlowVM.teamGameVM {
                    PlayerChooseGameView(teamGameVM: vm, teamFlowVM: teamFlowVM)
                }
            case .blindTestMaster:
                BlindTestMasterView(blindTestViewModel: masterFlowVM.makeBlindTestMasterVM())
            case .blindTestPlayer:
                if let teamGameVM = teamFlowVM.teamGameVM {
                    BuzzerPlayerView(teamGameVM: teamGameVM, gameType: .blindTest)
                }
            case .createTeamView:
                CreateTeamView(createTeamVM: teamFlowVM.makeCreateTeamViewModel())
            case .quizMaster:
                QuizMasterListView(quizMasterVM: masterFlowVM.makeQuizMasterVM())
            case .quizPlayer:
                if let teamGameVM = teamFlowVM.teamGameVM {
                    BuzzerPlayerView(teamGameVM: teamGameVM, gameType: .quiz)
                }
            case .scoreMaster:
                ScoreMasterView(masterFlowVM: masterFlowVM)
            case .scorePlayer:
                if let teamGameVM = teamFlowVM.teamGameVM {
                    ScorePlayerView(teamGameVM: teamGameVM)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(Router())
}
