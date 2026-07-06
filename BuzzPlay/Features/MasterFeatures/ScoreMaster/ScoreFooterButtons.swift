//
//  ScoreFooterButtons.swift
//  BuzzPlay
//
//  Barre d'actions bas d'écran du classement final : « Quitter » et « Nouvelle partie »,
//  posée sur un dégradé qui fond dans le fond. La logique (teardown / reset / nav) reste
//  au parent via les closures. Extrait de ScoreMasterView.
//

import SwiftUI

struct ScoreFooterButtons: View {
    let onQuit: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onQuit) {
                Text("Quitter")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: BuzzRadius.lg)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onNewGame) {
                Text("Nouvelle partie")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    )
                    .shadow(color: Color.greenButtonLeading.opacity(0.32), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.bottom, BuzzSpacing.xxxl)
        .padding(.top, BuzzSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.sheetBg.opacity(0), Color.sheetBg],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
