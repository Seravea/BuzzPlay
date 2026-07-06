//
//  MasterConfirmOverlay.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Overlay confirmation Master

struct MasterConfirmOverlay: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xxl) {
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .textStyle(Typography.largeTitle)
                        .foregroundStyle(LinearGradient(
                            colors: [Color.blueLeading, Color.blueTrailing],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))

                    Text("Prêt à mener la danse ?")
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Tu vas animer la partie en tant qu'hôte. Les joueurs pourront te rejoindre depuis leur iPhone.")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: BuzzSpacing.md) {
                    Button(action: onCancel) {
                        Text("Annuler")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                    }

                    Button(action: onConfirm) {
                        Text("C'est parti !")
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
