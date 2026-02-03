//
//  LobbyMasterViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import SwiftUI

struct LobbyMasterView: View {
    @EnvironmentObject var router: Router
    @Bindable var masterGameVM: MasterLobbyViewModel
    var body: some View {
        VStack {
            Text("Salle d'attente")
                .font(.nohemi(.largeTitle, weight: .bold))
            
            Spacer()
            if masterGameVM.teams.isEmpty {
                ProgressView {
                    Text("Aucune équipe n'a rejoint pour l'instant")
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Équipes connectées (\(masterGameVM.teams.count))")
                        .padding(.leading)
                        .padding(.bottom, -8)
                        .font(.nohemi(.title, weight: .semiBold))
                    ScrollView {
                        VStack {
                            ForEach(masterGameVM.teams) { team in
                                TeamCardView(team: team, isWining: false, showPoints: false)
                                    .padding(.trailing)
                            }
                        }
                    }
                    
                    StartingButtonView(iconName: "play", size: .largeTitle, buttonLabel: "Démarrer la partie") {
                        router.push(.masterChooseGameView)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .appDefaultTextStyle(Typography.body)
        .background(
            BackgroundAppView()
        )
        
    }
}

#Preview {
    LobbyMasterView(masterGameVM: MasterLobbyViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}
