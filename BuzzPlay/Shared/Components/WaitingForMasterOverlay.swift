//
//  WaitingForMasterOverlay.swift
//  BuzzPlay
//

import SwiftUI
import UIKit

struct WaitingForMasterOverlay: View {
    // #conn-phase — phase réelle de connexion MPC (recherche → connexion). On NE montre
    // jamais les erreurs/retries bruts (« Unable to connect ») : juste une progression calme.
    var phase: MPCConnectionPhase = .searching
    // #conn-help — après un délai de recherche infructueuse (ou permission Réseau local
    // refusée), on affiche une aide diagnostic actionnable au lieu de laisser l'écran figé.
    var showHelp: Bool = false
    var onRetry: () -> Void = {}
    @Environment(\.openURL) private var openURL
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
                    Text(phase == .connecting ? "Connexion à l'hôte…" : "Recherche de l'hôte…")
                        .font(.nohemi(.title2, weight: .bold)).titleTracking()
                        .foregroundStyle(.white)

                    Text(phase == .connecting
                         ? "On établit la connexion, ça arrive…"
                         : "Vérifie que le Maître a bien lancé une partie à proximité.")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .animation(.buzzFade, value: phase)
                }

                // Dots animés
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        DotsIndicator(index: i)
                    }
                }
                .padding(.top, 4)

                // #conn-help — aide diagnostic après un délai de recherche infructueuse.
                if showHelp { helpSection }
            }
            .padding(.horizontal, BuzzSpacing.xxxl)
            .padding(.vertical, 28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
            .animation(.buzzFade, value: showHelp)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulseScale = 1.35
                pulseOpacity = 0.0
            }
        }
    }

    // MARK: - Aide diagnostic (#conn-help)

    private var helpSection: some View {
        VStack(spacing: BuzzSpacing.md) {
            Rectangle()
                .fill(Color.textFaint.opacity(0.3))
                .frame(height: 1)
                .padding(.top, 4)

            VStack(spacing: BuzzSpacing.xs) {
                Text("Toujours rien ?")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("Vérifie que :\n•  le Maître a bien lancé une partie\n•  « Réseau local » est autorisé pour BuzzPlay\n•  le Wi-Fi et le Bluetooth sont activés")
                    .font(.nohemi(.footnote, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: BuzzSpacing.sm) {
                Button(action: onRetry) {
                    Text("Réessayer")
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BuzzSpacing.md)
                        .background(LinearGradient.buzzPrimary, in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                }
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                } label: {
                    Text("Ouvrir les Réglages")
                        .font(.nohemi(.subheadline, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
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
