//
//  CoinsView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import SwiftUI

struct CoinsView: View {
   @Bindable var coinsVM: CoinsViewModel
    var body: some View {
        
        VStack {
            if coinsVM.masterFlowViewModel != nil {
                
                CoinsMasterView(coinsVM: coinsVM)
                
            } else {
                
                CoinsTeamView(coinsVM: coinsVM)
                
            }
            
            Spacer()
        }
        
    }
}

#Preview {
    VStack {
        CoinsView(coinsVM: CoinsViewModel(masterFlowVM: MasterFlowViewModel()))
        CoinsView(coinsVM: CoinsViewModel(teamFlowVM: TeamFlowViewModel()))
        
    }
}




