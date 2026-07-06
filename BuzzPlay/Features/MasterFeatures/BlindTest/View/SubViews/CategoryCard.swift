//
//  CategoryCard.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Category Card

struct CategoryCard: View {
    let item: CategoryItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    LinearGradient(colors: item.colors,
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))

                    Image(systemName: item.icon)
                        .textStyle(Typography.screenTitle)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                }
                .frame(width: 74, height: 74)

                Text(item.label)
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
