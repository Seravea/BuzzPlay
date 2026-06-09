//
//  BPWordmarkView.swift
//  BuzzPlay
//

import SwiftUI

/// Wordmark "Zik•jeu" — point rouge-rose, "jeu" en jaune moutarde.
struct BPWordmarkView: View {
    var size: CGFloat = 56

    private var dotSize: CGFloat { size * 0.20 }
    private var dotHPad: CGFloat { size * 0.065 }
    private var dotVOffset: CGFloat { size * 0.08 }

    var body: some View {
        HStack(spacing: 0) {
            Text("Zik")
                .foregroundStyle(.white)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.redLeading, Color.purpleTrailing],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: dotSize, height: dotSize)
                .padding(.horizontal, dotHPad)
                .offset(y: dotVOffset)

            Text("jeu")
                .foregroundStyle(Color.mustardYellow)
        }
        .font(.custom("Nohemi-Black", size: size))
        .tracking(-1.5)
        .lineLimit(1)
    }
}

#Preview {
    BPWordmarkView(size: 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundAppView())
}
