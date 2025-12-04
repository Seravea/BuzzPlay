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
            Text("Lobby Master")
            
            Spacer()
            if masterGameVM.teams.isEmpty {
                ProgressView {
                    Text("Aucune équipe n'a rejoint pour l'instant")
                }
            } else {
                VStack {
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(masterGameVM.teams) { team in
                                TeamCardView(team: team, isWining: false)
                            }
                        }
                    }
                    
                    PrimaryButtonView(title: "Commencer la partie", action: {
                        router.push(.masterChooseGameView)
                    }, style: .filled(color: .mustardYellow), fontSize: Typography.title)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    LobbyMasterView(masterGameVM: MasterLobbyViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}
