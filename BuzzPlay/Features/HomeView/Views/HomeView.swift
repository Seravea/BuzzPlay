//
//  TeamChooserView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @State var teamFlowVM = TeamFlowViewModel()
    @State var masterFlowVM = MasterFlowViewModel()
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                
                Text("Zik'jeu")
                    .font(.poppins(.largeTitle, weight: .bold))
                
                  Spacer()
                
                VStack {
                    HStack {
                        //MARK: Destination to PlayerView
                        PrimaryButtonView(title: "Joueurs", action: {
                            router.push(.createTeamView)
                        }, style: .filled(color: .darkestPurple), fontSize: Typography.body)
                        
                        //MARK: Destination to MasterView
                        PrimaryButtonView(title: "Maître", action: {
                            router.push(.masterLobbyView)
                        }, style: .outlined(color: .darkestPurple), fontSize: Typography.body, size: 400)
                        
                    }
                    
                    PrimaryButtonView(title: "Partage d'écran", action: {
                        router.push(.createPublicDisplayTeam)
                    }, style: .filled(color: .mustardYellow), fontSize: Typography.body)
                    
                }
                .padding()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .homeView:
                        HomeView()
                    case .masterChooseGameView:
                        MasterChooseGameView(masterChooseGameVM: masterFlowVM.makeChooseGameVM())
                    case .masterLobbyView:
                        //TODO: view
                        LobbyMasterView(masterGameVM: masterFlowVM.makeLobbyViewModel())
                    case .playerChooseGameView:
                        //TODO: view
                        if let vm = teamFlowVM.teamGameVM {
                            PlayerChooseGameView(teamGameVM: vm, teamFlowVM: teamFlowVM)
                        } else {
                            Text("Pas de team Gros Bug sa reum")
                        }
                    case .blindTestMaster:
                        BlindTestMasterView(blindTestViewModel: masterFlowVM.makeBlindTestMasterVM())
                    case .blindTestPlayer:
                        //TODO: view
                        if let teamGameVM = teamFlowVM.teamGameVM {
                            
                            BuzzerPlayerView(teamGameVM: teamGameVM)
                                
                        }
                        
                    case .createTeamView:
                        //TODO: view
                        CreateTeamView(createTeamVM: teamFlowVM.makeCreateTeamViewModel())
                        
                    case .quizMaster:
                        //TODO: View
                        QuizMasterListView(quizMasterVM: masterFlowVM.makeQuizMasterVM())
                    case .quizPlayer:
                        if let teamGameVM = teamFlowVM.teamGameVM {
                            BuzzerPlayerView(teamGameVM: teamGameVM)
                        }
                    case .createPublicDisplayTeam:
                        CreateDisplayPublicTeamView(createTeamVM: teamFlowVM.makeCreateTeamViewModel())
                    case .publicDisplayScreen:
                        if let teamGameVM = teamFlowVM.teamGameVM {
                            
                            PublicDisplayView(teamGameVM: teamGameVM)
                        }
                    case .karaoke:
                        EmptyView()
                    }
                }
                Spacer()
                
            }
            .onAppear {
                teamFlowVM.restoreSavedTeamIfPossible()
            }
            .appDefaultTextStyle(Typography.body)
        }
    }
}

#Preview {
    
    HomeView()
        .environmentObject(Router())
}
