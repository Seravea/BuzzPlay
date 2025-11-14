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
                
                HStack {
                    //MARK: Destination to PlayerView
                    PrimaryButtonView(title: "Joueurs", action: {
                        router.push(.createTeamView)
                    }, style: .filled(color: .darkestPurple), fontSize: Typography.largeTitle)
                     
                    //MARK: Destination to MasterView
                    PrimaryButtonView(title: "Maître", action: {
                        router.push(.masterLobbyView)
                    }, style: .outlined(color: .darkestPurple), fontSize: Typography.largeTitle)
                  
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .homeView:
                        HomeView()
                    case .masterChooseGameView:
                       EmptyView()
                    case .masterLobbyView:
                        //TODO: view
                        LobbyMasterViewModel(masterGameVM: masterFlowVM.makeLobbyViewModel())
                    case .playerChooseGameView:
                        //TODO: view
                        if let vm = teamFlowVM.teamGameVM {
                            PlayerChooseGameView(teamGameVM: vm)
                        } else {
                            Text("Pas de team Gros Bug sa reum")
                        }
                    case .blindTest:
                        //TODO: view
                        BuzzerPlayerView(buzzerVM: teamFlowVM.makeBuzzerViewModel(for: .blindTest))
                    case .createTeamView:
                        //TODO: view
                        CreateTeamView(createTeamVM: teamFlowVM.makeCreateTeamViewModel())
                 
                    }
                }
                
                Spacer()
                
            }
            .appDefaultTextStyle(Typography.body)
        }
    }
}

#Preview {
    
    HomeView()
        .environmentObject(Router())
}
