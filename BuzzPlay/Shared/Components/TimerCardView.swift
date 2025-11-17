//
//  TimerCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

struct TimerCardView: View {
    var timer: String
    var isCorrectAnswer: Bool
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
            if isCorrectAnswer {
                Text("Bonne Réponse !")
                    .padding(.bottom)
            }
            
        }
        .font(.poppins(.largeTitle, weight: .bold))
        .foregroundStyle(.white)
        
        .appDefaultTextStyle(Typography.largeTitle)
    }
}


#Preview {
    TimerCardView(timer: "00:00:01", isCorrectAnswer: true)
}
