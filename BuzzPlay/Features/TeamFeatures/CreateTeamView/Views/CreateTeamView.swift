//
//  CreateTeamView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct CreateTeamView: View {
    @Bindable var createTeamVM: CreateTeamViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 24) {
                TextFieldCustom(
                    text: $createTeamVM.team.name,
                    prompt: "Nom de l'équipe",
                    textSize: .largeTitle
                )
                
                Text("De 1 à 6 joueurs")
                    .font(.poppins(.largeTitle, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach($createTeamVM.team.players) { $player in
                        HStack {
                            TextFieldCustom(
                                text: $player.name,
                                prompt: "Nom du joueur",
                                textSize: .title3
                            )
                            
                            PrimaryButtonView(title: "Supprimer", action: {
                                createTeamVM.removePlayer(player: player)
                            }, style: .filled(color: .red), fontSize: Typography.title3, sfIconName: "trash.fill", iconSize: .title3, colorIcon: .white, size: geo.size.width * 0.15)
                            .padding(.leading)
                        }
                        
                    }
                    
                   
                        PrimaryButtonView(
                            title: "Ajouter un joueur \(createTeamVM.nbofPlayers)/6",
                            action: {
                                withAnimation {
                                    createTeamVM.team.players.append(Player(name: ""))
                                }
                            },
                            style: .filled(color: createTeamVM.nbofPlayers > 6 ? .gray : .mustardYellow),
                            fontSize: Typography.largeTitle,
                            sfIconName: "plus.circle.fill",
                            iconSize: .largeTitle,
                            colorIcon: .white,
                            size: geo.size.width * 0.3
                        )
                        .disabled(createTeamVM.nbofPlayers > 5)
                    }
                
                Spacer()
                
                PrimaryButtonView(title: "Valider la team", action: {
                    createTeamVM.isAlertOn.toggle()
                }, style: .filled(color: .green), fontSize: Typography.largeTitle)
                
            }
            .alert("Es-tu sûr des prénoms de tes joueurs ?", isPresented: $createTeamVM.isAlertOn) {
                Button("Annuler", role: .destructive) {
                    createTeamVM.isAlertOn = false
                }
                
                Button("Continuer", role: .cancel) {
                    createTeamVM.validate()
                    router.push(.playerChooseGameView)
                }
                
            }
            
        }
        .padding()
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    CreateTeamView(createTeamVM: CreateTeamViewModel())
}
