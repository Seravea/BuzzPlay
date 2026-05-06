//
//  GameCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct ButtonGameCardView: View {
    var gameTitle: String
    var action: () -> Void

    var body: some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text(gameTitle)
                .font(.nohemi(.title2, weight: .bold))
                .foregroundStyle(.black)
                .padding()
                .frame(width: 300, height: 500)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.mustardYellow)
                }
                .shadow(color: Color.mustardYellow.opacity(0.4), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ButtonGameCardView(gameTitle: "Blind Test", action: { })
}
