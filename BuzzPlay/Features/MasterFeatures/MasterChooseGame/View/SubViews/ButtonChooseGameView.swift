//
//  ButtonChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct ButtonChooseGameView: View {
    let isOpen: Bool
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
                .frame(width: geo.size.width / 5, height: geo.size.height / 2)
                .background {
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.darkestPurple)
                            .opacity(isOpen ? 1 : 0.8)
                        Text(isOpen ? "Open" : "Close")
                            .foregroundStyle(isOpen ? Color.darkestPurple : Color.white)
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(isOpen ? .green : .red)
                                    .padding()
                            }
                        
                    }
                }
        }
        .disabled(!isOpen)
       
    }
}


#Preview {
    GeometryReader { geo in
        ButtonChooseGameView(isOpen: false, geo: geo, action: {}, title: "BlindTest")
    }
}
