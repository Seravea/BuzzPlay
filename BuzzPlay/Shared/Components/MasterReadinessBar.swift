//
//  MasterReadinessBar.swift
//  BuzzPlay
//
//  #invite-progress (G2 v1) — feedback visuel côté Master : combien de joueurs ont
//  confirmé leur présence sur le buzzer (readyAndConnectedCount / totalPlayersCount).
//  Rend lisible le moment où le garde-fou #E1 attend tout le monde avant de lancer.
//  Pur affichage, aucune donnée réseau nouvelle.
//

import SwiftUI

struct MasterReadinessBar: View {
    let ready: Int
    let total: Int
    /// Hauteur fixe (alignée sur le bouton « Réinviter » dans InviteProgressRow).
    var height: CGFloat = 50

    private var done: Bool { total > 0 && ready >= total }
    private var fraction: Double { total > 0 ? min(1, Double(ready) / Double(total)) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: done ? "checkmark.circle.fill" : "person.wave.2.fill")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(done ? Color.greenGlow : Color.mustardYellow)
                Text(done ? "Tous les joueurs sont prêts" : "Joueurs prêts sur le buzzer")
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(ready)/\(total)")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(done ? Color.greenGlow : Color.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.10)).frame(height: 5)
                    Capsule()
                        .fill(done
                              ? AnyShapeStyle(Color.greenGlow)
                              : AnyShapeStyle(LinearGradient(colors: [Color.mustardYellow, Color.yellowTrailing],
                                                             startPoint: .leading, endPoint: .trailing)))
                        .frame(width: geo.size.width * fraction, height: 5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: ready)
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, BuzzSpacing.md)
        .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
        .glassCard(radius: BuzzRadius.md)
        .animation(.buzzFade, value: done)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        VStack(spacing: 16) {
            MasterReadinessBar(ready: 1, total: 3)
            MasterReadinessBar(ready: 3, total: 3)
        }
        .padding()
    }
}
