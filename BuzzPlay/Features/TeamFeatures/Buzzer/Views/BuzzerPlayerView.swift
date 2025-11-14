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
            Text(textTEST)
            ZStack {
                
                Image(.buttonFloor)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 240)
                Image(.buttonTap)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 320, height: 230)
                    .padding(.bottom, isTapped ? 10 : 100)  
            }
            .onTapGesture {
                buzzerVM.buzz()
                textTEST = buzzerVM.team.name
                isTapped.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isTapped.toggle()
                }
            }
            .animation(.easeInOut(duration: 0.1), value: isTapped)
            
           
//            .frame(height: 400)
        }
    }
}

#Preview {
    BuzzerPlayerView(buzzerVM: BuzzerViewModel(team: Team(name: "L'équipe 1", colorIndex: 0), mode: .blindTest))
}
