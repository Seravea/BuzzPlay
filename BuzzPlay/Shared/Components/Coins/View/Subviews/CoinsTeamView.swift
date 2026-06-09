//
//  CoinsTeamView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 19/11/2025.
//


import SwiftUI

struct CoinsTeamView: View {
    @Bindable var coinsVM: CoinsViewModel
    var body: some View {
        VStack(spacing: BuzzSpacing.sm) {
            HStack(spacing: 6) {
                Text("\(coinsVM.playerGameViewModel?.player.accountAmount ?? 0)")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
                Image(systemName: "dollarsign.bank.building.fill")
                    .foregroundStyle(Color.mustardYellow)
            }

            Menu {
                ForEach(CoinsViewModel.Gift.allCases, id: \.self) { gift in
                    if gift.requiresTargetPlayer {
                        if coinsVM.otherPlayers.isEmpty {
                            Button {} label: {
                                Text("\(gift.title) — \(gift.price) $ (aucun adversaire)")
                            }
                            .disabled(true)
                        } else {
                            Menu {
                                ForEach(coinsVM.otherPlayers) { enemy in
                                    Button {
                                        coinsVM.buyGift(gift, targeting: enemy)
                                    } label: {
                                        Text(enemy.name)
                                    }
                                }
                            } label: {
                                Text("\(gift.title) — \(gift.price) $")
                            }
                        }
                    } else {
                        Button {
                            coinsVM.buyGift(gift)
                        } label: {
                            Text("\(gift.title) — \(gift.price) $")
                        }
                    }
                }
            } label: {
                Text("Cadeaux")
                    .primaryButtonTextStyle(.filled(buttonStyle: .neutral), fontSize: Typography.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BuzzSpacing.sm)
                    .background {
                        RoundedRectangle.backgroundPrimaryButton(style: .filled(buttonStyle: .secondary))
                    }
            }

            if let error = coinsVM.errorMessage {
                Text(error)
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: 140, alignment: .trailing)
    }
}
