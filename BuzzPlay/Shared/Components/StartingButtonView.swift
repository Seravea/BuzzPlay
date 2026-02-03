//
//  StartingButtonView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 21/01/2026.
//

import SwiftUI

struct StartingButtonView: View {
    var iconName: String
    var size: Font.TextStyle
    var buttonLabel: String
    let action: () -> Void
    var body: some View {
        Button {
            
            action()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.nohemi(size))
                Text(buttonLabel)
            }
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .font(.nohemi(size))
            .padding(.vertical, 16)
            .padding(.horizontal, 48)
            .background(
                Capsule()
                    .foregroundStyle(
                        LinearGradient(colors: [.greenButtonLeading, .greenButtonTrailing], startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
    }
}

#Preview {
    StartingButtonView(iconName: "play", size: .largeTitle, buttonLabel: "Démarrer la partie", action: {})
}
