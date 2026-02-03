//
//  ChooseRoleCardsView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/01/2026.
//

import SwiftUI

struct ChooseRoleCardsView: View {
    var roleButtonUI: RoleButtonUI
    var body: some View {
        VStack {
            Image(systemName: roleButtonUI.iconName)
                .font(.largeTitle)
                .frame(width: 90, height: 90)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(roleButtonUI.linearGradient)
                )
            Text(roleButtonUI.displayNameText)
                .font(.nohemi(.title, weight: .bold))
            Text(roleButtonUI.displayDescText)
                .multilineTextAlignment(.center)
                .font(.nohemi(.body))
                .opacity(0.7)
        }
        .foregroundStyle(.white)
        .frame(width: 338, height: 272)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(.white.opacity(0.1))
        )
    }
}

#Preview {
    ChooseRoleCardsView(roleButtonUI: .master)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundAppView())
}
