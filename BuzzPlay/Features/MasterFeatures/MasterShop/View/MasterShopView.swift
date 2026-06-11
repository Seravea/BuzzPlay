//
//  MasterShopView.swift
//  BuzzPlay
//
//  #v1-packs — A4 / M1 : boutique vitrine des packs de quiz, poussée depuis le hub
//  Master. On vend du CONTENU (packs thématiques Non-Consumable, ~0,99 €) — achat via
//  QuizPackStore (mock V1 → StoreKit 2 réel ensuite). La liste vient de
//  RemoteQuizPackCatalog. Décision Romain « les packs = les catégories ».
//

import SwiftUI

struct MasterShopView: View {

    private var catalog: RemoteQuizPackCatalog { RemoteQuizPackCatalog.shared }
    private var store: QuizPackStore { QuizPackStore.shared }
    private var packs: [RemoteQuizPack] { catalog.packs }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BuzzSpacing.xl) {
                header

                if packs.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: BuzzSpacing.md) {
                        ForEach(packs) { pack in
                            PackShopCard(
                                pack: pack,
                                isUnlocked: store.isUnlocked(pack),
                                purchaseState: store.purchaseState,
                                onBuy: { store.purchase(pack) }
                            )
                        }
                    }

                    Button("Restaurer mes achats") { store.restorePurchases() }
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, BuzzSpacing.sm)
                }
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.top, BuzzSpacing.lg)
            .padding(.bottom, BuzzSpacing.xxxl)
        }
        .foregroundStyle(.white)
        .background(BackgroundAppView())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Boutique")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .masterDarkNavBar()  // #8 — nav bar sombre cohérente côté Master
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text("Packs de quiz")
                .font(.nohemi(.title, weight: .extraBold)).titleTracking()
                .foregroundStyle(.white)
            Text("Débloque des thèmes prêts à jouer. Achat unique, dispo toute la soirée.")
                .font(.nohemi(.subheadline, weight: .regular))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Empty state (offline au 1er lancement, pas encore de cache)

    private var emptyState: some View {
        VStack(spacing: BuzzSpacing.md) {
            Image(systemName: "wifi.slash")
                .textStyle(Typography.sectionTitle)
                .foregroundStyle(Color.textMuted)
            Text("Aucun pack chargé")
                .font(.nohemi(.headline, weight: .bold))
                .foregroundStyle(.white)
            Text("Connecte-toi à internet au moins une fois pour télécharger les packs. Ils restent ensuite disponibles hors-ligne.")
                .font(.nohemi(.caption, weight: .regular))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BuzzSpacing.xxxl)
    }
}

// MARK: - Pack Card (vitrine + achat inline)

private struct PackShopCard: View {
    let pack: RemoteQuizPack
    let isUnlocked: Bool
    let purchaseState: PackPurchaseState
    let onBuy: () -> Void

    private var theme: QuizTheme { pack.theme }
    private var questionCount: Int { pack.sets.reduce(0) { $0 + $1.questions.count } }

    private var isPurchasingThis: Bool {
        if case .purchasing(let id) = purchaseState { return id == pack.productID }
        return false
    }
    private var isAnyPurchasing: Bool {
        if case .purchasing = purchaseState { return true }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            // En-tête : icône + titre + compteur + statut
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: theme.iconName)
                    .textStyle(Typography.cardTitle)
                    .foregroundStyle(theme.color)
                    .frame(width: 48, height: 48)
                    .background(theme.color.opacity(0.18), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(theme.color.opacity(0.35), lineWidth: 1))

                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.title)
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(pack.sets.count) quiz · \(questionCount) questions")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                statusBadge
            }

            // Aperçu : quelques titres de quiz
            if !pack.sets.isEmpty {
                VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                    ForEach(pack.sets.prefix(3)) { set in
                        HStack(spacing: BuzzSpacing.sm) {
                            Image(systemName: "music.note")
                                .textStyle(Typography.caption2)
                                .foregroundStyle(theme.color.opacity(0.8))
                            Text(set.title)
                                .font(.nohemi(.caption, weight: .regular))
                                .foregroundStyle(Color.textTertiary)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    if pack.sets.count > 3 {
                        Text("+ \(pack.sets.count - 3) autres")
                            .font(.nohemi(.caption2, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.leading, 2)
            }

            // CTA d'achat (uniquement pour un premium encore verrouillé)
            if pack.isPremium && !isUnlocked {
                Button(action: onBuy) {
                    Group {
                        if isPurchasingThis {
                            ProgressView().tint(.white)
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.open.fill")
                                    .textStyle(Typography.captionEM)
                                Text("Débloquer — \(pack.priceDisplay ?? "achat unique")")
                                    .font(.nohemi(.subheadline, weight: .bold))
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isAnyPurchasing)
                .opacity(isAnyPurchasing && !isPurchasingThis ? 0.5 : 1)
            }
        }
        .padding(BuzzSpacing.md)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.xl)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var statusBadge: some View {
        if !pack.isPremium {
            badge(text: "Inclus", icon: "checkmark", color: Color.greenGlow)
        } else if isUnlocked {
            badge(text: "Débloqué", icon: "checkmark.seal.fill", color: Color.greenGlow)
        } else {
            badge(text: pack.priceDisplay ?? "Premium", icon: "lock.fill", color: Color.mustardYellow)
        }
    }

    private func badge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .textStyle(Typography.caption2)
            Text(text)
                .font(.nohemi(.caption, weight: .bold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(color.opacity(0.30), lineWidth: 1))
    }
}
