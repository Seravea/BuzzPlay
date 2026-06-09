//
//  WaitingForMasterOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct WaitingForMasterOverlay: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.70)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xl) {

                // Icône pulsante arcade
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.buzzHotPink.opacity(0.25), Color.purpleLeading.opacity(0.15)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.buzzHotPink, Color.mustardYellow],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: BuzzSpacing.sm) {
                    Text("En attente du Maître")
                        .font(.nohemi(.title2, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Le Maître doit lancer la partie\ndepuis son appareil")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Dots animés
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        DotsIndicator(index: i)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, BuzzSpacing.xxxl)
            .padding(.vertical, 28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulseScale = 1.35
                pulseOpacity = 0.0
            }
        }
    }
}

// MARK: - Dots Indicator

private struct DotsIndicator: View {
    let index: Int
    @State private var isActive = false

    var body: some View {
        Circle()
            .fill(isActive ? Color.buzzHotPink : Color.textFaint)
            .frame(width: 7, height: 7)
            .scaleEffect(isActive ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.18).repeatForever(autoreverses: true), value: isActive)
            .onAppear { isActive = true }
    }
}

#Preview {
    WaitingForMasterOverlay()
}
