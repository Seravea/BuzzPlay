//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterChooseGameView: View {
    @Bindable var masterChooseGameVM: MasterChooseGameViewModel
    @EnvironmentObject private var router: Router
    @State var isOpen: Bool = false
    
    
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 32) {
                    
                  
                        ForEach(masterChooseGameVM.allGames, id: \.self) { game in
                            VStack {
                                
                                ButtonChooseGameView(isOpen: masterChooseGameVM.gameIsAvailable(game), action: {
                                    //ROUTER destination BlindTest
                                    
                                    router.push(game.destinationMaster)
                                    
                                    
                                }, title: game.gameTitle, iconName: game.iconName)
                                
                                
                                HStack{
                                    
                                    PrimaryButtonView(title: "Ouvrir", action: {
                                        //MARK: ouvrir la game
                                        masterChooseGameVM.addGame(game)
                                    }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                                    .disabled(masterChooseGameVM.gameIsAvailable(game))
                                    .opacity(masterChooseGameVM.gameIsAvailable(game) ? 0.8 : 1)
                                    PrimaryButtonView(title: "Fermer", action: {
                                        //MARK: fermer la game
                                        masterChooseGameVM.removeGame(game)
                                    }, style: .outlined(buttonStyle: .destructive), fontSize: Typography.body)
                                    .disabled(!masterChooseGameVM.gameIsAvailable(game))
                                    .opacity(!masterChooseGameVM.gameIsAvailable(game) ? 0.8 : 1)
                                }
                                
                            }
                            
                            
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
            }
//            .background(Color.backgroundColor)
            
        }
        .background(
            BackgroundAppView()
        )
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    MasterChooseGameView(masterChooseGameVM: MasterChooseGameViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}


