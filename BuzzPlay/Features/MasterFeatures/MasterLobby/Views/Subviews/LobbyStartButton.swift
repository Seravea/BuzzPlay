//
//  LobbyStartButton.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Start Button

struct LobbyStartButton: View {
    @Bindable var masterGameVM: MasterLobbyViewModel
    /// Action de démarrage (démarrage partie + navigation) fournie par le parent.
    let onStart: () -> Void

    var body: some View {
        // #config-explicite — verrouillé tant que la config n'est pas complète (+ ≥ 1 joueur).
        let enabled = masterGameVM.canStart
        return VStack(spacing: BuzzSpacing.sm) {
            if let hint = masterGameVM.startHint {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .textStyle(Typography.caption2EM)
                    Text(hint)
                        .font(.nohemi(.caption, weight: .semiBold))
                }
                .foregroundStyle(Color.textMuted)
                .transition(.opacity)
            }

            Button {
                onStart()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .textStyle(Typography.labelBold)
                    Text("Commencer la partie")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(enabled ? .white : Color.textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    enabled
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        : AnyShapeStyle(Color.white.opacity(0.10)),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                )
                .shadow(
                    color: enabled ? Color.greenButtonLeading.opacity(0.32) : .clear,
                    radius: 12, y: 4
                )
            }
            .buttonStyle(.plain)
            .disabled(!enabled)
        }
        .animation(.buzzDefault, value: enabled)
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
