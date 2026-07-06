//
//  NewGameNotificationOverlay.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - New Game Notification Overlay (#B6)

struct NewGameNotificationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.60).ignoresSafeArea()

            VStack(spacing: BuzzSpacing.lg) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.purpleLeading)

                VStack(spacing: 6) {
                    Text("Nouvelle partie !")
                        .font(.custom("Nohemi-Black", size: 26))
                        .tracking(1)
                        .foregroundStyle(.white)
                    Text("Le Master relance une partie")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.60))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                    .fill(.ultraThinMaterial.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                        .strokeBorder(Color.purpleLeading.opacity(0.35), lineWidth: 1.5))
            )
            .padding(.horizontal, 40)
        }
    }
}
