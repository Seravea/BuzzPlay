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
        VStack {
            HStack {
                Text("\(coinsVM.teamFlowViewModel?.team?.score ?? 0)")
                
                Image(systemName: "dollarsign.bank.building.fill")
                    .foregroundStyle(Color.mustardYellow)
            }
            Menu {
                
                ForEach(CoinsViewModel.Gift.allCases, id: \.self) { gift in
                    Button {
                        gift.giftAction()
                    } label: {
                        Text("\(gift.title) -> \(gift.price)$")
                    }
                }
                
            } label: {
                
                Text("Acheter")
                    .primaryButtonTextStyle(.filled(color: .white), fontSize: Typography.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle.backgroundPrimaryButton(style: .filled(color: .mustardYellow))
                    }
                
            }
        }
        .frame(maxWidth: 130, alignment: .trailing)
    }
}