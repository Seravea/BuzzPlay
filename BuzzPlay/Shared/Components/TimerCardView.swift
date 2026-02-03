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
        
        
       
            
        VStack(spacing: 8) {
                
                Text("Chrono")
                
                Text("\(timer)")
                   
            }
            .padding()
            .background {
                Rectangle()
                    .foregroundStyle(Color.darkestPurple)
            }
        
        .font(.nohemi(.body, weight: .bold))
        .foregroundStyle(.white)
    }
}


#Preview {
    TimerCardView(timer: "00:01", isCorrectAnswer: true)
}
