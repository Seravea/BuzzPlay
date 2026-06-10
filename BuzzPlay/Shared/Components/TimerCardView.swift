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
        
        
       
            
        VStack(spacing: BuzzSpacing.sm) {
                
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
        // #B3 — agrandi + icône pour que le timer Player se lise au premier coup d'œil
        // (avant : .callout, nombre nu peu visible en trailing).
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.nohemi(.subheadline, weight: .bold))
            Text(time)
                .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: time)
        }
        .foregroundStyle(Color.mustardYellow)
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 7)
        .background(Color.mustardYellow.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.30), lineWidth: 1))
    }
}

#Preview {
    TimerCardView(timer: "00:01", isCorrectAnswer: true)
    TimerBadge(time: "00:42")
}
