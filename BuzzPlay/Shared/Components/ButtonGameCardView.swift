//
//  GameCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct ButtonGameCardView: View {
//    var geo: GeometryProxy
    var gameTitle: String
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(gameTitle)
                .foregroundStyle(.black)
                .padding()
                .frame(width: 300, height: 500)
//                .frame(width: geo.size.width * 0.25, height: geo.size.height * 0.5)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.mustardYellow)
                }
        }
    }
}

#Preview {
    ButtonGameCardView(gameTitle: "Blind Test", action: { })
}
