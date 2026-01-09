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
                //MARK: Saved team draft (optional)
                if createTeamVM.hasSavedTeamDraft {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team sauvegardée détectée")
                            .font(.poppins(.title3, weight: .bold))
                        Text("\"\(createTeamVM.savedTeamDraft?.name ?? "No Name")\" • \(createTeamVM.savedTeamDraft?.players.filter { !$0.name.isEmpty }.count ?? 0) joueur(s)")
                            .font(.poppins(.body))
                            .opacity(0.8)

                        HStack(spacing: 12) {
                            PrimaryButtonView(
                                title: "Utiliser",
                                action: {
                                    createTeamVM.useSavedTeamDraft()
                                    createTeamVM.didLoadSavedTeam = true
                                },
                                style: .filled(color: .mustardYellow),
                                fontSize: Typography.body
                            )

                            PrimaryButtonView(
                                title: "Nouveau",
                                action: {
                                    createTeamVM.resetForm()
                                    createTeamVM.didLoadSavedTeam = true
                                },
                                style: .outlined(color: .darkestPurple),
                                fontSize: Typography.body
                            )

                            PrimaryButtonView(
                                title: "Supprimer",
                                action: {
                                    createTeamVM.deleteSavedTeamDraft()
                                },
                                style: .filled(color: .red),
                                fontSize: Typography.body,
                                sfIconName: "trash.fill",
                                iconSize: .body,
                                colorIcon: .white
                            )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                HStack(spacing: 24) {
                    TextFieldCustom(
                        text: $createTeamVM.team.name,
                        prompt: "Nom de l'équipe",
                        textSize: .body
                    )
                    HStack(spacing: 12) {
                        ForEach(GameColor.allCases, id: \.self) { color in
                            Button {
                                createTeamVM.team.teamColor = color
                            } label: {
                                Circle()
                                    .frame(height: 52)
                                    .foregroundStyle(Color(color.rawValue))
                                    .opacity(createTeamVM.isSelectedGameColor(color))
                            }

                        }
                    }
                }
                HStack {
                    Text("De 1 à 6 joueurs")
                        .font(.poppins(.title3, weight: .bold))
                    
                    Spacer()
                    
                    PrimaryButtonView(
                        title: "Ajouter un joueur \(createTeamVM.nbofPlayers)/6",
                        action: {
                            withAnimation {
                                createTeamVM.team.players.append(Player(name: ""))
                            }
                        },
                        style: .filled(color: createTeamVM.nbofPlayers > 6 ? .gray : .mustardYellow),
                        fontSize: Typography.body,
                        sfIconName: "plus.circle.fill",
                        iconSize: .title3,
                        colorIcon: .white,
                        size: geo.size.width * 0.4
                    )
                    .disabled(createTeamVM.nbofPlayers > 5)
                }
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($createTeamVM.team.players) { $player in
                            HStack {
                                TextFieldCustom(
                                    text: $player.name,
                                    prompt: "Nom du joueur",
                                    textSize: .body
                                )
                                
                                PrimaryButtonView(title: "Supprimer", action: {
                                    createTeamVM.removePlayer(player: player)
                                }, style: .filled(color: .red), fontSize: Typography.body, sfIconName: "trash.fill", iconSize: .body, colorIcon: .white, size: geo.size.width * 0.4)
                                .padding(.leading)
                            }
                            
                        }
                        
                        
                        
                    }
                }
                
            
                
                PrimaryButtonView(title: "Valider la team", action: {
                    createTeamVM.isAlertOn.toggle()
                }, style: .filled(color: .green), fontSize: Typography.body)
                
            }
            .alert("Es-tu sûr des prénoms de tes joueurs ?", isPresented: $createTeamVM.isAlertOn) {
                Button("Annuler", role: .destructive) {
                    createTeamVM.isAlertOn = false
                }
                
                Button("Continuer", role: .cancel) {
                    createTeamVM.validate(isPublicDisplay: false)
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
