//
//  LoadingCardView.swift
//  BuzzPlay
//

import SwiftUI

struct LoadingCardView: View {
    let message: String
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.mustardYellow.opacity(0.1))
                    .frame(width: 64, height: 64)
                    .blur(radius: 4)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0 : 0.8)

                ProgressView()
                    .scaleEffect(1.4)
                    .tint(Color.mustardYellow)
            }

            Text(message)
                .font(.nohemi(.body, weight: .semiBold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Cela ne devrait prendre que quelques secondes")
                .font(.nohemi(.caption))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.08), lineWidth: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionLabel: String?

    init(
        icon: String,
        title: String,
        message: String,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
        self.actionLabel = actionLabel
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.white.opacity(0.3))

            Text(title)
                .font(.nohemi(.title2, weight: .bold))
                .foregroundStyle(.white)

            Text(message)
                .font(.nohemi(.subheadline))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            if let action = action, let label = actionLabel {
                Button(action: action) {
                    Text(label)
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.purpleLeading, Color.purpleTrailing],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 32) {
        LoadingCardView(message: "Chargement de la playlist…")

        EmptyStateView(
            icon: "music.note.list",
            title: "Aucune playlist",
            message: "Cherche une playlist Apple Music pour commencer",
            action: {},
            actionLabel: "Commencer la recherche"
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(BackgroundAppView())
}
