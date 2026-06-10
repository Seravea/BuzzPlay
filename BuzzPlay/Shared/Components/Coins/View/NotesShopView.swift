//
//  NotesShopView.swift
//  BuzzPlay
//

import SwiftUI

struct NotesShopView: View {
    @Bindable var store: NotesStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: BuzzSpacing.xl) {
                    header
                    packsList
                    disclaimer
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color.sheetBg, location: 0),
                    .init(color: Color.darkestPurple, location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    // MARK: - Top bar (drag handle + bouton fermer)

    private var topBar: some View {
        ZStack {
            // Drag handle centré
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.textFaint)
                .frame(width: 36, height: 4)

            // #D4 — bouton fermer explicite (la sheet est non-draggable sur Mac/iPad)
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.nohemi(.footnote, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Fermer la boutique")
            }
            .padding(.trailing, BuzzSpacing.lg)
        }
        .padding(.top, BuzzSpacing.md)
        .padding(.bottom, BuzzSpacing.xxl)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: "music.note")
                    .textStyle(Typography.sectionTitle)
                    .foregroundStyle(Color.mustardYellow)
                Text("\(store.balance)")
                    .font(.nohemi(.largeTitle, weight: .black)).titleTracking()
                    .foregroundStyle(Color.mustardYellow)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.spring(response: 0.4), value: store.balance)
            }
            Text("Notes disponibles")
                .font(.nohemi(.caption, weight: .regular))
                .foregroundStyle(Color.textTertiary)

            if case .success(let amount) = store.purchaseState {
                SuccessConfirmation(amount: amount)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.purchaseState == .idle)
    }

    // MARK: - Packs

    private var packsList: some View {
        // Bonus de valeur vs le pack le moins avantageux (l'intro), en %.
        // Plus parlant que "X Notes / €" et évite le côté comptable (#D2).
        let baseRate = store.packs.map(\.notesPerEuro).min() ?? 1
        return VStack(spacing: 10) {
            ForEach(store.packs) { pack in
                PackCard(
                    pack: pack,
                    bonusPercent: bonusPercent(for: pack, baseRate: baseRate),
                    purchaseState: store.purchaseState,
                    onBuy: { store.purchase(pack) }
                )
            }
        }
    }

    /// % de Notes en plus (à prix égal) qu'avec le pack de base, arrondi au
    /// multiple de 10 pour rester un argument marketing rond, pas un calcul.
    private func bonusPercent(for pack: NotesPack, baseRate: Int) -> Int {
        guard baseRate > 0 else { return 0 }
        let raw = pack.notesPerEuro * 100 / baseRate - 100
        return Int((Double(raw) / 10).rounded()) * 10
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("Les Notes sont consommables et ne périment jamais.\nAchats gérés par Apple — aucune souscription.")
            .font(.nohemi(.caption2, weight: .regular))
            .foregroundStyle(Color.textTertiary)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, BuzzSpacing.sm)
    }
}

// MARK: - Pack Card

private struct PackCard: View {
    let pack: NotesPack
    let bonusPercent: Int
    let purchaseState: PurchaseState
    let onBuy: () -> Void

    private var isThisPurchasing: Bool {
        if case .purchasing(let id) = purchaseState { return id == pack.id }
        return false
    }

    private var anyPurchasing: Bool {
        if case .purchasing = purchaseState { return true }
        return false
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icône + badge meilleure valeur
            ZStack(alignment: .topTrailing) {
                Image(systemName: "music.note.list")
                    .textStyle(Typography.sectionTitleSoft)
                    .foregroundStyle(Color.mustardYellow)
                    .frame(width: 52, height: 52)
                    .background(Color.mustardYellow.opacity(0.14), in: RoundedRectangle(cornerRadius: BuzzRadius.md))

                if pack.isBestValue {
                    Text("⭐")
                        .textStyle(Typography.caption)
                        .offset(x: 6, y: -6)
                }
            }

            // Texte
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: BuzzSpacing.sm) {
                    Text("\(pack.notes) Notes")
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                    if pack.isBestValue {
                        Text("MEILLEURE VALEUR")
                            .font(.nohemi(.caption2, weight: .bold))
                            .tracking(0.4)
                            .foregroundStyle(Color.greenButtonLeading)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.greenButtonLeading.opacity(0.12), in: Capsule())
                    }
                }
                if bonusPercent > 0 {
                    Text("+\(bonusPercent)% de bonus")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.greenButtonLeading)
                } else {
                    Text("Pack Découverte")
                        .font(.nohemi(.caption2, weight: .regular))
                        .foregroundStyle(Color.textMuted)
                }
            }

            Spacer()

            // CTA
            Button(action: onBuy) {
                Group {
                    if isThisPurchasing {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                            .frame(width: 64, height: 34)
                    } else {
                        Text(pack.priceDisplay)
                            .font(.nohemi(.callout, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 64)
                            .padding(.horizontal, BuzzSpacing.md)
                            .frame(height: 34)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [Color.yellowLeading, Color.yellowTrailing],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.sm2)
                )
            }
            .buttonStyle(.plain)
            .disabled(anyPurchasing)
            .opacity(anyPurchasing && !isThisPurchasing ? 0.4 : 1)
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(
                    pack.isBestValue ? Color.greenButtonLeading.opacity(0.30) : .white.opacity(0.09),
                    lineWidth: pack.isBestValue ? 1.5 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isThisPurchasing)
    }
}

// MARK: - Confirmation succès

private struct SuccessConfirmation: View {
    let amount: Int
    @State private var scale = 0.8

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.greenButtonLeading)
            Text("+\(amount) Notes ajoutées !")
                .font(.nohemi(.callout, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, 10)
        .background(Color.greenButtonLeading.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
                .strokeBorder(Color.greenButtonLeading.opacity(0.30), lineWidth: 1)
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.buzzBouncy) { scale = 1 }
        }
    }
}

#Preview {
    NotesShopView(
        store: NotesStore(masterFlowVM: MasterFlowViewModel())
    )
    .presentationDetents([.large])
}
