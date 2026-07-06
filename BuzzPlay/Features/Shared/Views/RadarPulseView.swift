//
//  RadarPulseView.swift
//  BuzzPlay
//
//  Vue partagée : animation radar « en attente ». Utilisée par le Quiz
//  (QuizActiveQuestionScreen) et le Blind Test (BlindTestActiveScreen).
//

import SwiftUI

// MARK: - Radar Pulse Animation

struct RadarPulseView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .strokeBorder(Color.textSecondary, lineWidth: 1.5)
                    .frame(width: animate ? 36 : 8, height: animate ? 36 : 8)
                    .opacity(animate ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.6),
                        value: animate
                    )
            }
            Circle()
                .fill(Color.textSecondary)
                .frame(width: 6, height: 6)
        }
        .frame(width: 36, height: 36)
        .onAppear { animate = true }
    }
}
