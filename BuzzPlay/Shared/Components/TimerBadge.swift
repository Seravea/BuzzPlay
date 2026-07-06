//
//  TimerBadge.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import SwiftUI

/// Badge compact du chrono — affiché dans la zone question côté Player.
struct TimerBadge: View {
    let time: String

    var body: some View {
        // #B3 — agrandi + icône pour que le timer Player se lise au premier coup d'œil
        // (avant : .callout, nombre nu peu visible en trailing).
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.nohemi(.subheadline, weight: .bold))
            // #timer-jitter — Nohemi n'a pas de chiffres à chasse fixe → `.monospacedDigit()` ne
            // suffit pas. Gabarit caché « 00 » = plancher 2 chiffres ; le ZStack prend la taille du
            // plus grand → à 3 chiffres (attente > 99 s, rare) ça grandit tout seul, jamais de « … ».
            ZStack(alignment: .trailing) {
                Text(verbatim: "00").hidden()
                Text(time)
            }
            .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
            .monospacedDigit()
        }
        .foregroundStyle(Color.mustardYellow)
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 7)
        .background(Color.mustardYellow.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.30), lineWidth: 1))
    }
}

#Preview {
    TimerBadge(time: "00:42")
}
