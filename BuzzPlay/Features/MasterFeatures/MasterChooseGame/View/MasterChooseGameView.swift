//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterChooseGameView: View {
    @State var masterChooseGameVM: MasterChooseGameViewModel
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
                                
                                ButtonChooseGameView(isOpen: masterChooseGameVM.gameIsAvailable(game), geo: geo, action: {
                                    //ROUTER destination BlindTest
                                    
                                        router.push(game.destination)
                                    
                                    
                                }, title: game.gameTitle)
                               
                                
                                HStack{
                                    
                                    PrimaryButtonView(title: "Ouvrir", action: {
                                        //MARK: ouvrir la game
                                        masterChooseGameVM.addGame(game)
                                    }, style: .outlined(color: .darkestPurple), fontSize: Typography.title)
                                    
                                    PrimaryButtonView(title: "Fermer", action: {
                                        //MARK: fermer la game
                                        masterChooseGameVM.removeGame(game)
                                    }, style: .filled(color: .darkestPurple), fontSize: Typography.title)
                                    
                                }
                                
                            }
                           
                        }
                        //                HStack(spacing: 32) {
                        //                    
                        //                    VStack {
                        //                        
                        //                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                        //                            //ROUTER destination BlindTest
                        //                        }, title: "Blind Test")
                        //                        
                        //                        HStack{
                        //                            
                        //                            PrimaryButtonView(title: "Ouvrir", action: {
                        //                                //MARK: ouvrir la game
                        //                            }, style: .outlined(color: .darkestPurple), fontSize: Typography.title)
                        //                           
                        //                            PrimaryButtonView(title: "Fermer", action: {
                        //                                //MARK: fermer la game
                        //                            }, style: .filled(color: .darkestPurple), fontSize: Typography.title)
                        //                            
                        //                        }
                        //                        
                        //                    }
                        //                    VStack {
                        //                        
                        //                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                        //                            //ROUTER destination Quiz
                        //                        }, title: "Quiz")
                        //                        
                        //                        HStack{
                        //                            
                        //                            PrimaryButtonView(title: "Ouvrir", action: {
                        //                                //MARK: ouvrir la game
                        //                            }, style: .outlined(color: .darkestPurple), fontSize: Typography.title)
                        //                           
                        //                            PrimaryButtonView(title: "Fermer", action: {
                        //                                //MARK: fermer la game
                        //                            }, style: .filled(color: .darkestPurple), fontSize: Typography.title)
                        //                            
                        //                        }
                        //                    }
                        //                    
                        //                    VStack {
                        //                        
                        //                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                        //                            //ROUTER destination Kara OKÉ
                        //                        }, title: "Kara OKÉ")
                        //                        
                        //                        HStack{
                        //                            
                        //                            PrimaryButtonView(title: "Ouvrir", action: {
                        //                                //MARK: ouvrir la game
                        //                            }, style: .outlined(color: .darkestPurple), fontSize: Typography.title)
                        //                           
                        //                            PrimaryButtonView(title: "Fermer", action: {
                        //                                //MARK: fermer la game
                        //                            }, style: .filled(color: .darkestPurple), fontSize: Typography.title)
                        //                            
                        //                        }
                        //                    }
                        //                    
                        //                    //                    Spacer()
                        //                    
                        //                }
//                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
                
                Spacer()
                
            }
            
        }
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    MasterChooseGameView(masterChooseGameVM: MasterChooseGameViewModel(gameVM: MasterFlowViewModel()))
}


