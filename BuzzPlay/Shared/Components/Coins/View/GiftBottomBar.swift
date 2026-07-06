//
//  GiftBottomBar.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Bottom Bar (toujours visible en bas du buzzer)

struct GiftBottomBar: View {
    @Bindable var coinsVM: CoinsViewModel
    @Binding var isSheetOpen: Bool
    var isWaiting: Bool = false

    @State private var glowPulse = false

    private var balance: Int { PlayerNotesWallet.shared.balance }  // #v1-economy — solde local

    var body: some View {
        VStack(spacing: BuzzSpacing.sm) {
            if isWaiting && balance > 0 {
                Text("\(Image(systemName: "sparkles")) C'est le moment d'utiliser tes Notes !")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.mustardYellow)
                    .pillStyle(fill: Color.mustardYellow.opacity(0.12),
                               stroke: Color.mustardYellow.opacity(0.35),
                               compact: true)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button { isSheetOpen = true } label: {
                // alignement .firstTextBaseline : les icônes (gift, banque, chevron) se posent
                // sur la ligne de base du texte (Nohemi calée haut → .center les désalignait).
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "gift.fill")
                        .textStyle(Typography.labelSM)
                        .foregroundStyle(Color.mustardYellow)

                    Text("Cadeaux")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    // solde + banque même couleur (jaune) → icône interpolée dans le Text :
                    // même taille + ligne de base alignées (un HStack laissait le chiffre plus haut).
                    Text("\(balance) \(Image(systemName: "dollarsign.bank.building.fill"))")
                        .font(.nohemi(.callout, weight: .extraBold))
                        .monospacedDigit()
                        .foregroundStyle(Color.mustardYellow)

                    Image(systemName: "chevron.up")
                        .textStyle(Typography.caption2Bold)
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(
                    isWaiting ? Color.mustardYellow.opacity(0.10) : .white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                        .strokeBorder(
                            isWaiting ? Color.mustardYellow.opacity(0.55) : .white.opacity(0.12),
                            lineWidth: isWaiting ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isWaiting ? Color.mustardYellow.opacity(glowPulse ? 0.40 : 0.12) : .clear,
                    radius: glowPulse ? 16 : 6
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .animation(.buzzSmooth, value: isWaiting)
        .onChange(of: isWaiting) { _, waiting in
            if waiting {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            } else {
                glowPulse = false
            }
        }
        .onAppear {
            if isWaiting {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}
