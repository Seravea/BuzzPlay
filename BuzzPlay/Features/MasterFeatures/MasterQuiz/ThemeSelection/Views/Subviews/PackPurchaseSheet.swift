//
//  PackPurchaseSheet.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - #v1-packs — sheet d'achat d'un pack premium (StoreKit mock V1)

struct PackPurchaseSheet: View {
    let pack: RemoteQuizPack
    @Environment(\.dismiss) private var dismiss

    private var store: QuizPackStore { QuizPackStore.shared }

    private var isPurchasing: Bool {
        if case .purchasing = store.purchaseState { return true }
        return false
    }

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            Image(systemName: pack.theme.iconName)
                .font(.system(size: 44))   // taille SF Symbol — intentionnel
                .foregroundStyle(pack.theme.color)
                .padding(.top, BuzzSpacing.xl)

            VStack(spacing: BuzzSpacing.xs) {
                Text(pack.theme.title)
                    .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                    .foregroundStyle(.white)
                Text("\(pack.sets.count) quiz · disponible pour toute la soirée")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Button {
                store.purchase(pack)
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text("Débloquer — \(pack.priceDisplay ?? "achat unique")")
                            .font(.nohemi(.body, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.md)
                .background(
                    LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                )
            }
            .buttonStyle(.plain)
            .disabled(isPurchasing)

            Button("Restaurer mes achats") { store.restorePurchases() }
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .padding(.bottom, BuzzSpacing.lg)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        // Achat confirmé → la card se déverrouille derrière, on ferme la sheet.
        .onChange(of: store.purchaseState) { _, state in
            if case .success = state { dismiss() }
        }
    }
}
