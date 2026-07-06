//
//  PulseRingView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Pulse ring animé

struct PulseRingView: View {
    let delay: Double
    let color: Color
    @State private var animate = false

    var body: some View {
        Circle()
            .strokeBorder(color.opacity(0.40), lineWidth: 1.5)
            .frame(width: 280, height: 280)
            .scaleEffect(animate ? 1.40 : 0.85)
            .opacity(animate ? 0 : 0.70)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}
