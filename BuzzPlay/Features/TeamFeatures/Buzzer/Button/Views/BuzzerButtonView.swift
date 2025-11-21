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
            
            Spacer()
            
            if let teamName = buzzerVM.teamNameHasBuzz {
                
                Text("\(teamName) a buzzer")
                    .font(.poppins(.largeTitle, weight: .bold))
                
            } else {
                
                Text("UI emptyView")
                    .foregroundStyle(.clear)
                    .font(.largeTitle)
                
            }
            
            Spacer()
            
            ZStack {
                
                
                Image(.buttonFloor)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 240)
                    .opacity(buzzerVM.isEnabled ? 1 : 0.5)
                Image(.buttonTap)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 320, height: 230)
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
            
           Spacer()
//            .frame(height: 400)
        }
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    BuzzerButtonView(buzzerVM: BuzzerViewModel(team: Team(name: "L'équipe 1", teamColor: .blueGame), mode: .blindTest))
}
