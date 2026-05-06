//
//  CoinsMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 19/11/2025.
//


import SwiftUI

struct CoinsMasterView: View {
   @Bindable var coinsVM: CoinsViewModel
    var body: some View {
        if let masterFlowVM = coinsVM.masterFlowViewModel {
            VStack {
                
                HStack {
                    PrimaryButtonView(title: "Cadeaux", action: {
                        withAnimation {
                            coinsVM.isSendingOpen.toggle()
                        }
                        
                        
                        
                    }, style: .filled(buttonStyle: .neutral), fontSize: Typography.body, sfIconName: "dollarsign.bank.building.fill", iconSize: .body, colorIcon: .white)
                }
                .frame(maxWidth: 130)
                
                
                if coinsVM.isSendingOpen {
                    
                    
                    HStack {
                        ForEach(masterFlowVM.players) { player in
                            Menu {
                                ForEach(coinsVM.moneyCanSend, id: \.self) { money in

                                    Button {
                                        //SEND money to player
                                    } label: {
                                        Text("\(money) $")
                                    }
                                }
                            } label: {
                                PrimaryButtonView(title: player.name, action: {}, style: .filled(buttonStyle: .neutral), fontSize: Typography.body)
                                    .frame(maxWidth: 120)

                            }
                            
                        }
                    }
                    
                    .transition(.move(edge: .top).combined(with: .opacity))
                    //
                    
                    
                }
                
            }
        }
    }
}
