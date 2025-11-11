//
//  TeamChooserView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct TeamChooserView: View {
    @EnvironmentObject private var router: Router
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                
                Text("Zik'jeu")
                    .font(.poppins(.largeTitle, weight: .bold))
                
                  Spacer()
                
                HStack {
                    //MARK: Destination to PlayerView
                    PrimaryButtonView(title: "Joueurs", action: {router.push(.playerView)}, style: .filled, fontSize: .largeTitle)
                     
                    //MARK: Destination to MasterView
                    PrimaryButtonView(title: "Maître", action: {
                        router.push(.masterView)
                    }, style: .outlined, fontSize: .largeTitle)
                  
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .homeView:
                        TeamChooserView()
                    case .masterView:
                        //TODO: view
                        //MasterView()
                        EmptyView()
                    case .playerView:
                        //TODO: view
                        //PlayerView()
                        EmptyView()
                    case .quizView:
                        //TODO: view
                        //QuizView
                        EmptyView()
                    case .settingsView:
                        //TODO: view
                        //SettingsView
                        EmptyView()
                    }
                }
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    TeamChooserView()
}
