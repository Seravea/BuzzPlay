//
//  BuzzerPlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BuzzerButtonView: View {
    @State var isTapped: Bool = false
    @Bindable var buzzerVM: BuzzerViewModel
    
    var body: some View {
        VStack {
            
            ZStack {
                
                
                Image(.buttonFloor)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320, maxHeight: 230)
                    .opacity(buzzerVM.isEnabled ? 1 : 0.5)
                Image(.buttonTap)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 240)
                    .padding(.bottom, isTapped ? 10 : 100)
                    
            }
            .opacity(buzzerVM.isEnabled ? 1 : 0.7)
            .onTapGesture {
                if buzzerVM.isEnabled {
                    buzzerVM.buzz()
                    isTapped.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isTapped.toggle()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.1), value: isTapped)
            
        }
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    BuzzerButtonView(buzzerVM: BuzzerViewModel(team: Team(name: "L'équipe 1", teamColor: .blueGame), mode: .blindTest))
}
