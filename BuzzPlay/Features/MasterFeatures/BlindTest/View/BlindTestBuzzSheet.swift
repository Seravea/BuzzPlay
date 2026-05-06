//
//  BlindTestBuzzSheet.swift
//  BuzzPlay
//

import SwiftUI

struct BlindTestBuzzSheet: View {
    let player: Player
    let reactionTime: String
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 99)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

            Text("A BUZZÉ !")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.5)

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(player.teamColor.gradient)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(player.name.prefix(1)))
                            .font(.nohemi(.title3, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                    
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("RÉACTION")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.5)
                    Text(reactionTime)
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(Color.mustardYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(player.teamColor.gradient)
                    .frame(width: 4)
                    .padding(.leading, 0)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            HStack(spacing: 8) {
                validationButton(points: 10, scale: 0.88)
                validationButton(points: 20, scale: 0.94)
                validationButton(points: 30, scale: 1.0, highlighted: true)
            }

            Button(action: onReject) {
                Text("Refuser la réponse ✕")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6B70"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(hex: "#FB2C36").opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#FB2C36").opacity(0.35), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .background(Color(hex: "#1A0535"), in: RoundedRectangle(cornerRadius: 28))
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func validationButton(points: Int, scale: CGFloat, highlighted: Bool = false) -> some View {
        let responses = points / 10
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onValidate(points)
        } label: {
            VStack(spacing: 2) {
                Text("+\(points)")
                    .font(.nohemi(.title3, weight: .extraBold))
                Text("\(responses) réponse\(responses > 1 ? "s" : "")")
                    .font(.nohemi(.caption2, weight: .semiBold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                               startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .opacity(highlighted ? 1 : (scale < 0.9 ? 0.65 : 0.82))
            .shadow(color: highlighted ? Color.greenButtonLeading.opacity(0.4) : Color.greenButtonLeading.opacity(0.15), radius: 12, y: 4)
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestBuzzSheet(
            player: Player(name: "L'équipe", teamColor: .blueGame),
            reactionTime: "0.45s",
            onValidate: { _ in },
            onReject: {}
        )
    }
}
