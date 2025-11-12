//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterChooseGameView: View {
    @EnvironmentObject private var router: Router
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Spacer()
                
                HStack(spacing: 12) {
                    
//                    Spacer()
                    
                    ButtonChooseGameView(geo: geo, action: {
                        //ROUTER destination BuzzGame
                    }, title: "Buzz")
                    ButtonChooseGameView(geo: geo, action: {
                        //ROUTER destination BlindTest
                    }, title: "Blind Test")
                    ButtonChooseGameView(geo: geo, action: {
                        //ROUTER destination Quiz
                    }, title: "Quiz")
                    ButtonChooseGameView(geo: geo, action: {
                        //ROUTER destination Kara OKÉ
                    }, title: "Kara OKÉ")

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


