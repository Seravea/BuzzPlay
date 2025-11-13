//
//  TimerCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct TimerCardView: View {
    @Binding var timer: String
    var body: some View {
        
        
        ZStack(alignment: .bottom) {
            
            VStack {
                
                Text("Chrono")
                
                Text("\(timer)")
                   
            }
            .padding()
            .frame(minWidth: 400, minHeight: 400, alignment: .center)
            .background {
                Rectangle()
                //MARK: Couleur de l'équipe qui a buzzé
                    .foregroundStyle(Color.darkestPurple)
            }
            
            //MARK: Affiché si le master valide la réponse
            Text("Bonne Réponse !")
                .padding(.bottom)
        }
        .font(.poppins(.largeTitle, weight: .bold))
        .foregroundStyle(.white)
        
        .appDefaultTextStyle(Typography.largeTitle)
    }
}


#Preview {
    TimerCardView(timer: .constant("00:03"))
}
