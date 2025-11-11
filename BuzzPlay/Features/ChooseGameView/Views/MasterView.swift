//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    
                    Spacer()
                    
                    ButtonChooseGameView(geo: geo, action: {})
                    ButtonChooseGameView(geo: geo, action: {})
                    ButtonChooseGameView(geo: geo, action: {})
                    ButtonChooseGameView(geo: geo, action: {})

                    Spacer()
                    
                }
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
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: geo.size.width / 6, height: geo.size.height / 3)
                .foregroundStyle(Color.darkestPurple)
        }
    }
}
