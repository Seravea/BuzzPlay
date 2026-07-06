//
//  GiftShopSheet.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Gift Shop Sheet

struct GiftShopSheet: View {
    @Bindable var coinsVM: CoinsViewModel
    @Binding var isPresented: Bool

    @State private var showSoundPicker = false

    private let columns = [GridItem(.flexible(), spacing: BuzzSpacing.md), GridItem(.flexible(), spacing: BuzzSpacing.md)]
    private var balance: Int { PlayerNotesWallet.shared.balance }  // #v1-economy — solde local

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle (fixe)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.textFaint)
                .frame(width: 36, height: 4)
                .padding(.top, BuzzSpacing.md)
                .padding(.bottom, BuzzSpacing.xxl)

            // #S5 — contenu scrollable : sans scroll, le header était coupé sur iPhone
            // et la grille trop haute sur iPad.
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Boutique")
                                .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                                .foregroundStyle(.white)
                            Text("Active un cadeau pour changer le jeu")
                                .font(.nohemi(.caption, weight: .regular))
                                .foregroundStyle(Color.textTertiary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            // #notes-align — baseline commune + même taille de police → l'icône
                            // ne « flotte » plus au-dessus du nombre de Notes.
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text("\(balance)")
                                    .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
                                    .monospacedDigit()
                                    .foregroundStyle(Color.mustardYellow)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Image(systemName: "dollarsign.bank.building.fill")
                                    .font(.nohemi(.body, weight: .bold))
                                    .foregroundStyle(Color.mustardYellow)
                                    .layoutPriority(1)
                            }
                            Text("Notes disponibles")
                                .font(.nohemi(.caption2, weight: .regular))
                                .foregroundStyle(Color.textMuted)
                        }
                    }
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.xl)

                    // Grille de cadeaux
                    // #v1-shop — la couleur ALÉATOIRE payante est retirée de la V1 (résultat
                    // aléatoire contre paiement = loot-box, guideline 3.1.1). V2 = picker direct.
                    LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                        ForEach(CoinsViewModel.Gift.allCases.filter { $0 != .changeBuzzColor }, id: \.self) { gift in
                            GiftCardView(
                                gift: gift,
                                balance: balance,
                                isPending: coinsVM.isPendingPurchase,
                                hintAvailable: coinsVM.playerGameViewModel?.publicState.hintAvailable ?? false,
                                otherPlayers: coinsVM.otherPlayers,
                                player: coinsVM.playerGameViewModel?.player,
                                onBuy: { target in
                                    if gift == .changeBuzzSound {
                                        // Vérifie le solde avant d'ouvrir le picker ; sinon buyGift
                                        // affiche l'alerte "pas assez de Notes" (#alerte-solde-bas).
                                        if balance >= gift.price {
                                            showSoundPicker = true
                                        } else {
                                            coinsVM.buyGift(gift, targeting: target)
                                        }
                                    } else {
                                        coinsVM.buyGift(gift, targeting: target)
                                        if coinsVM.errorMessage == nil { isPresented = false }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // #S5 — erreur en OVERLAY flottant (avant : inline → poussait toute la grille vers le bas)
        .overlay(alignment: .top) {
            if let error = coinsVM.errorMessage {
                errorBanner(error)
            }
        }
        .animation(.buzzSmooth, value: coinsVM.errorMessage)
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerSheet(coinsVM: coinsVM, isShopPresented: $isPresented)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color.sheetBg, location: 0),
                    .init(color: Color.darkestPurple, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // #S5 — bannière d'erreur flottante : ne décale pas la grille (overlay, pas dans le flux).
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.nohemi(.caption, weight: .semiBold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 10)
        .background(Color.redSoft.opacity(0.95), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
        .shadow(color: .black.opacity(0.35), radius: 12, y: 4)
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.top, BuzzSpacing.sm)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
