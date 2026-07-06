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
                .font(.title3)
                .padding(.leading)
                .foregroundStyle(Color.darkPink)
                .symbolEffectsRemoved(!blindTestVM.isPlaying)
                .modifier(BounceSymbolEffectCompatible(isPlaying: blindTestVM.isPlaying))
                    
            Spacer()
            if let playerBuzzing = blindTestVM.playerHasBuzz {
                
                TeamCardView(player: playerBuzzing, buzzTime: blindTestVM.formattedTime, showPoints: false)
                
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

// MARK: - iOS 18 Compatibility Modifier
struct BounceSymbolEffectCompatible: ViewModifier {
    let isPlaying: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.symbolEffect(.bounce)
        } else {
            content
                .scaleEffect(isPlaying ? 1.0 : 0.95)
                .animation(.spring(duration: 0.4, bounce: 0.05), value: isPlaying)
        }
    }
}

#Preview {
    PublicMasterBlindTestView(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))

}
