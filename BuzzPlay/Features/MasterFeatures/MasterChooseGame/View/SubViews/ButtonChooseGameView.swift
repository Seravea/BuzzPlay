//
//  ButtonChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct ButtonChooseGameView: View {
    @Binding var isOpen: Bool
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
                        Text(isOpen == true ? "Open" : "Close")
                            .foregroundStyle(isOpen == true ? Color.darkestPurple : Color.white)
                            .padding(24)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(isOpen == true ? .green : .red)
                                    .padding()
                            }
                        
                    }
                }
        }
        .appDefaultTextStyle(Typography.body)
    }
}


#Preview {
    GeometryReader { geo in
        ButtonChooseGameView(isOpen: .constant(false), geo: geo, action: {}, title: "BlindTest")
    }
}
