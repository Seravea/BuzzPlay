//
//  NotesShopView.swift
//  BuzzPlay
//

import SwiftUI

struct NotesShopView: View {
    @Bindable var store: NotesStore
    let currentBalance: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            ScrollView {
                VStack(spacing: 20) {
                    header
                    packsList
                    disclaimer
                }
                .padding(.horizontal, 20)
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

    // MARK: - Drag handle

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(.white.opacity(0.25))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 24)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.mustardYellow)
                Text("\(currentBalance)")
                    .font(.nohemi(.largeTitle, weight: .black))
                    .foregroundStyle(Color.mustardYellow)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.spring(response: 0.4), value: currentBalance)
            }
            Text("Notes disponibles")
                .font(.nohemi(.caption, weight: .regular))
                .foregroundStyle(.white.opacity(0.45))

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
        VStack(spacing: 10) {
            ForEach(store.packs) { pack in
                PackCard(
                    pack: pack,
                    purchaseState: store.purchaseState,
                    onBuy: { store.purchase(pack) }
                )
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("Les Notes sont consommables et ne périment jamais.\nAchats gérés par Apple — aucune souscription.")
            .font(.nohemi(.caption2, weight: .regular))
            .foregroundStyle(.white.opacity(0.28))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 8)
    }
}

// MARK: - Pack Card

private struct PackCard: View {
    let pack: NotesPack
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
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.mustardYellow)
                    .frame(width: 52, height: 52)
                    .background(Color.mustardYellow.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))

                if pack.isBestValue {
                    Text("⭐")
                        .font(.system(size: 12))
                        .offset(x: 6, y: -6)
                }
            }

            // Texte
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
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
                Text("\(pack.notesPerEuro) Notes / €")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(0.40))
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
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [Color.yellowLeading, Color.yellowTrailing],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 10)
                )
            }
            .buttonStyle(.plain)
            .disabled(anyPurchasing)
            .opacity(anyPurchasing && !isThisPurchasing ? 0.4 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
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
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.greenButtonLeading)
            Text("+\(amount) Notes ajoutées !")
                .font(.nohemi(.callout, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.greenButtonLeading.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.greenButtonLeading.opacity(0.30), lineWidth: 1)
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { scale = 1 }
        }
    }
}

#Preview {
    NotesShopView(
        store: NotesStore(masterFlowVM: MasterFlowViewModel()),
        currentBalance: 250
    )
    .presentationDetents([.large])
}
