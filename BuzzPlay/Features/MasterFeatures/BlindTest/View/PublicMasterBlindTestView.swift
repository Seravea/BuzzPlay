//
//  PublicMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct PublicMasterBlindTestView: View {
    @ObservedObject var blindTestVM: BlindTestViewModel
    
    
    var body: some View {
        VStack {
            Text(blindTestVM.progressText)
                .font(.poppins(.largeTitle))
            
            ProgressView(value: blindTestVM.progressValue)
                .progressViewStyle(.linear)
           
            Image(systemName: blindTestVM.isPlaying == true ? "play.circle.fill" : "stop.circle.fill")
                    .font(.system(size: 150))
                    .padding(.leading)
                    .foregroundStyle(Color.darkPink)
                    .symbolEffectsRemoved(!blindTestVM.isPlaying)
                    .symbolEffect(.bounce)
                    
            Spacer()
            if let teamWining = blindTestVM.teamWining, let buzzTime = blindTestVM.buzzTime {
                
                TeamCardView(teamWining: teamWining, buzzTime: buzzTime)
                
            } else {
                
                TimerCardView(timer: $blindTestVM.gameTimer)
                
            }
            Spacer()
                
        }
        .frame(maxWidth: .infinity)
        .appDefaultTextStyle(Typography.body)
        .padding()
        
    }
}

#Preview {
    PublicMasterBlindTestView(blindTestVM: BlindTestViewModel())
      
}
