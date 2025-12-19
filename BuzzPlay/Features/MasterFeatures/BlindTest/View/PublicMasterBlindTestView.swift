//
//  PublicMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct PublicMasterBlindTestView: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    
    var body: some View {
        VStack {
           
            Image(systemName: blindTestVM.isPlaying == true ? "play.circle.fill" : "stop.circle.fill")
                    .font(.system(size: 150))
                    .padding(.leading)
                    .foregroundStyle(Color.darkPink)
                    .symbolEffectsRemoved(!blindTestVM.isPlaying)
                    .symbolEffect(.bounce)
                    
            Spacer()
            if let teamWining = blindTestVM.teamHasBuzz {
                
                TeamCardView(team: teamWining, buzzTime: blindTestVM.formattedTime)
                
            } else {
                
                TimerCardView(timer: blindTestVM.formattedTime, isCorrectAnswer: blindTestVM.isCorrect)
                
            }
            Spacer()
                
        }
        .frame(maxWidth: .infinity)
        .appDefaultTextStyle(Typography.body)
        .padding()
        
    }
}

#Preview {
    PublicMasterBlindTestView(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
      
}
