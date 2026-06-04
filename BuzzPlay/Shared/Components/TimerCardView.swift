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


/// Badge compact du chrono — affiché dans la zone question côté Player.
struct TimerBadge: View {
    let time: String

    var body: some View {
        Text(time)
            .font(.nohemi(.callout, weight: .extraBold))
            .foregroundStyle(Color.mustardYellow)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.default, value: time)
            .frame(minWidth: 52, alignment: .center)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.mustardYellow.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.30), lineWidth: 1))
    }
}

#Preview {
    TimerCardView(timer: "00:01", isCorrectAnswer: true)
    TimerBadge(time: "00:42")
}
