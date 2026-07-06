//
//  ResumePartyOverlay.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Overlay reprise de partie (#resume)

struct ResumePartyOverlay: View {
    let onResume: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xxl) {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .textStyle(Typography.largeTitle)
                        .foregroundStyle(LinearGradient(
                            colors: [Color.greenButtonLeading, Color.greenTrailing],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))

                    Text("Reprendre la partie ?")
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Une partie en cours a été interrompue. Reprends-la (manches et scores conservés) — les joueurs se reconnectent tout seuls.")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                VStack(spacing: BuzzSpacing.md) {
                    Button(action: onResume) {
                        Text("Reprendre")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.greenButtonLeading, Color.greenTrailing],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                            )
                    }

                    Button(action: onNewGame) {
                        Text("Nouvelle partie")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                    }
                }
            }
            .padding(28)
            .background(
                Color.sheetBg,
                in: RoundedRectangle(cornerRadius: BuzzRadius.sheet)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
            .padding(.horizontal, BuzzSpacing.xxl)
        }
    }
}
