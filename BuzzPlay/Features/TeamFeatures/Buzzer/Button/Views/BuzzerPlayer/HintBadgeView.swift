//
//  HintBadgeView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Hint Badge (gift showIndicies)

struct HintBadgeView: View {
    let hint: String

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.mustardYellow)
                Text(hint)
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .strokeBorder(Color.mustardYellow.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
