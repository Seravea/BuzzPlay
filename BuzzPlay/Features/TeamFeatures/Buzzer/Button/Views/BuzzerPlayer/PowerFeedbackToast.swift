//
//  PowerFeedbackToast.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Power Feedback Toast (S2 — blocage / bouclier)

struct PowerFeedbackToast: View {
    let feedback: PowerFeedback

    private var color: Color {
        switch feedback.tone {
        case .offense: Color.redLeading
        case .shield:  Color.blueLeading
        }
    }

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: BuzzSpacing.sm) {
                Image(systemName: feedback.symbol)
                    .textStyle(Typography.labelSMBold)
                    .foregroundStyle(color)
                Text(feedback.text)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.vertical, BuzzSpacing.md)
            .background(Color.darkPurple, in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.45), lineWidth: 1.5))
            .shadow(color: color.opacity(0.25), radius: 12, y: 4)
            .padding(.top, BuzzSpacing.sm)
            Spacer()
        }
    }
}
