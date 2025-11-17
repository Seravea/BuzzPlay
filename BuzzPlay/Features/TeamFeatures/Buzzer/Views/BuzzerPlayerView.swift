//
//  BuzzerPlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BuzzerPlayerView: View {
    @State var isTapped: Bool = false
    @Bindable var buzzerVM: BuzzerViewModel
    @State var textTEST: String = ""
    var body: some View {
        VStack {
          
            Spacer()
            
            if buzzerVM.teamNameHasBuzz.isEmpty {
                Text("UI emptyView")
                    .foregroundStyle(.clear)
                    .font(.largeTitle)
            } else {
                Text("\(buzzerVM.teamNameHasBuzz) a buzzer")
                    .font(.poppins(.largeTitle, weight: .bold))
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
                    textTEST = buzzerVM.team.name
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
    BuzzerPlayerView(buzzerVM: BuzzerViewModel(team: Team(name: "L'équipe 1", teamColor: .blueGame), mode: .blindTest))
}
