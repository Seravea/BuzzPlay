//
//  NotesToastView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Notes Toast

struct NotesToastView: View {
    let amount: Int

    var body: some View {
        // .firstTextBaseline — garde l'accent coloré de l'icône tout en l'alignant sur la
        // ligne de base du texte (Nohemi calée haut → un .center la ferait paraître basse).
        HStack(alignment: .firstTextBaseline, spacing: BuzzSpacing.sm) {
            Image(systemName: "dollarsign.bank.building.fill")
                .textStyle(Typography.labelSMBold)
                .foregroundStyle(Color.mustardYellow)
            Text("+\(amount) Notes reçues !")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.vertical, BuzzSpacing.md)
        .background(Color.darkPurple, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1.5))
        .shadow(color: Color.mustardYellow.opacity(0.25), radius: 12, y: 4)
        .padding(.top, BuzzSpacing.sm)
    }
}
