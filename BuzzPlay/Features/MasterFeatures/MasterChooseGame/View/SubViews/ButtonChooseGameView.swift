//
//  ButtonChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

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


#Preview {
    GeometryReader { geo in
        ButtonChooseGameView(geo: geo, action: {}, title: "BlindTest")
    }
}
