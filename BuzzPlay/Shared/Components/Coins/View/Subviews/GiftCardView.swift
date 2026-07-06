//
//  GiftCardView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Gift Card

struct GiftCardView: View {
    let gift: CoinsViewModel.Gift
    let balance: Int
    let isPending: Bool
    /// #chantier-indice — false quand aucun indice n'existe pour la manche en cours
    /// (questions IA / packs remote sans indice). Ne concerne que `.showIndicies`.
    let hintAvailable: Bool
    let otherPlayers: [Player]
    let player: Player?
    let onBuy: (Player?) -> Void

    private var canAfford: Bool { balance >= gift.price }
    private var notEnoughPlayers: Bool { otherPlayers.count < gift.minimumOtherPlayers }
    private var isOwned: Bool { gift.isActiveOnPlayer(player) }
    /// #chantier-indice — « Voir un indice » sans indice dispo = achat inutile (50 Notes
    /// perdues) → card grisée/non-interactive comme un blocage structurel.
    private var hintUnavailable: Bool { gift == .showIndicies && !hintAvailable }
    /// Blocages structurels rendant la card non-interactive. Le solde insuffisant
    /// n'en fait PAS partie : la card reste tappable pour afficher l'alerte
    /// "pas assez de Notes" (#alerte-solde-bas).
    private var isBlocked: Bool { notEnoughPlayers || isPending || isOwned || hintUnavailable }
    /// Abordable ET jouable — pilote le rendu (card grisée si false).
    private var isActive: Bool { canAfford && !isBlocked }

    var body: some View {
        Group {
            // Cadeau abordable nécessitant une cible → menu de sélection.
            if gift.requiresTargetPlayer && !notEnoughPlayers && canAfford {
                Menu {
                    ForEach(otherPlayers) { enemy in
                        Button(enemy.name) { onBuy(enemy) }
                    }
                } label: { cardBody }
                .disabled(isPending || isOwned)
                .buttonStyle(.plain)
            } else {
                // Bouton simple : tappable même si solde insuffisant (buyGift affiche
                // alors l'alerte), désactivé seulement pour un blocage structurel.
                Button { onBuy(nil) } label: { cardBody }
                .buttonStyle(.plain)
                .disabled(isBlocked)
            }
        }
    }

    private var cardBody: some View {
        VStack(spacing: 10) {
            Image(systemName: gift.iconName)
                .textStyle(Typography.screenTitleSoft)
                .foregroundStyle(isActive ? gift.accentColor : .white.opacity(0.22))
                .frame(width: 54, height: 54)
                .background(
                    isActive ? gift.accentColor.opacity(0.18) : .white.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                )
                .overlay(alignment: .topTrailing) {
                    if isOwned {
                        Text("Actif")
                            .font(.nohemi(.caption2, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.greenButtonLeading, in: Capsule())
                            .offset(x: 6, y: -6)
                    }
                }

            Text(gift.shortTitle)
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(isActive ? .white : .white.opacity(0.28))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(gift.price) \(Image(systemName: "dollarsign.bank.building.fill"))")
                .font(.nohemi(.caption2, weight: .extraBold))
                .foregroundStyle(isActive ? Color.mustardYellow : .white.opacity(0.22))
                .pillStyle(fill: isActive ? Color.mustardYellow.opacity(0.12) : .white.opacity(0.05),
                           stroke: nil,
                           compact: true,
                           trailingIcon: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BuzzSpacing.lg)
        .padding(.horizontal, 6)
        .background(
            isActive ? gift.accentColor.opacity(0.07) : .white.opacity(0.03),
            in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(
                    isActive ? gift.accentColor.opacity(0.28) : .white.opacity(0.05),
                    lineWidth: 1
                )
        )
        .animation(.buzzDefault, value: isActive)
    }
}
