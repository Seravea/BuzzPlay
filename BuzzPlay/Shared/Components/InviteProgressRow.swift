//
//  InviteProgressRow.swift
//  BuzzPlay
//
//  #invite-progress — une fois les joueurs invités : barre « X/Y prêts » à gauche +
//  bouton « Réinviter » à droite, actif UNIQUEMENT s'il manque des joueurs sur le buzzer
//  (ready < total). Demande Romain au test : fusionner avancement et ré-invite sur une ligne.
//

import SwiftUI

struct InviteProgressRow: View {
    let ready: Int
    let total: Int
    let onReinvite: () -> Void

    private var missing: Bool { total > 0 && ready < total }

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            MasterReadinessBar(ready: ready, total: total)
                .frame(maxWidth: .infinity)

            Button(action: onReinvite) {
                VStack(spacing: 3) {
                    Image(systemName: "person.wave.2.fill")
                        .font(.nohemi(.footnote, weight: .bold))
                    Text("Réinviter")
                        .font(.nohemi(.caption2, weight: .bold))
                }
                .foregroundStyle(missing ? .white : Color.textTertiary)
                .frame(width: 78)
                .padding(.vertical, BuzzSpacing.sm)
                .background(
                    missing
                    ? AnyShapeStyle(LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                                   startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color.white.opacity(0.06)),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BuzzRadius.md)
                        .strokeBorder(.white.opacity(missing ? 0 : 0.10), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!missing)
            .animation(.buzzFade, value: missing)
        }
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        VStack(spacing: 16) {
            InviteProgressRow(ready: 1, total: 3, onReinvite: {})
            InviteProgressRow(ready: 3, total: 3, onReinvite: {})
        }
        .padding()
    }
}
