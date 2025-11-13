//
//  TeamChooserView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
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
                        //MasterView()
                        EmptyView()
                    case .playerChooseGameView:
                        //TODO: view
                        
                        EmptyView()
                    case .buzzerView:
                        //TODO: view
                        //QuizView
                        BuzzerPlayerView(teamPlaying: nil)
                    case .createTeamView:
                        //TODO: view
                        CreateTeamView()
                        EmptyView()
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
