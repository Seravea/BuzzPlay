//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterChooseGameView: View {
    @EnvironmentObject private var router: Router
    @State var isOpen: Bool = false
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Spacer()
                
                HStack(spacing: 32) {
                    
                    VStack {
                        
                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                            //ROUTER destination BlindTest
                        }, title: "Blind Test")
                        
                        HStack{
                            
                            PrimaryButtonView(title: "Ouvrir", action: {
                                //MARK: ouvrir la game
                            }, style: .outlined, fontSize: .title)
                           
                            PrimaryButtonView(title: "Fermer", action: {
                                //MARK: fermer la game
                            }, style: .filled, fontSize: .title)
                            
                        }
                        
                    }
                    VStack {
                        
                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                            //ROUTER destination Quiz
                        }, title: "Quiz")
                        
                        HStack{
                            
                            PrimaryButtonView(title: "Ouvrir", action: {
                                //MARK: ouvrir la game
                            }, style: .outlined, fontSize: .title)
                           
                            PrimaryButtonView(title: "Fermer", action: {
                                //MARK: fermer la game
                            }, style: .filled, fontSize: .title)
                            
                        }
                    }
                    
                    VStack {
                        
                        ButtonChooseGameView(isOpen: $isOpen, geo: geo, action: {
                            //ROUTER destination Kara OKÉ
                        }, title: "Kara OKÉ")
                        
                        HStack{
                            
                            PrimaryButtonView(title: "Ouvrir", action: {
                                //MARK: ouvrir la game
                            }, style: .outlined, fontSize: .title)
                           
                            PrimaryButtonView(title: "Fermer", action: {
                                //MARK: fermer la game
                            }, style: .filled, fontSize: .title)
                            
                        }
                    }
                    
                    //                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
            }
            
        }
        
    }
}

#Preview {
    MasterChooseGameView()
}


