//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterView: View {
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
    MasterView()
}

struct ButtonChooseGameView: View {
    var geo: GeometryProxy
    let action: () -> Void
    let title: String
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.poppins(.headline, weight: .black))
                .foregroundStyle(.white)
                .frame(width: geo.size.width / 6, height: geo.size.height / 2)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.darkestPurple)
                }
        }
        .appDefaultTextStyle(Typography.body)
    }
}
