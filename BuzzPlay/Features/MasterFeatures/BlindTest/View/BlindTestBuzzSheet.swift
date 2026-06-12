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
            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

            Text("A BUZZÉ !")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(0.5)

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .fill(player.teamColor.gradient)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(player.name.prefix(1)))
                            .font(.nohemi(.title3, weight: .bold)).titleTracking()
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
                        .foregroundStyle(Color.textSecondary)
                        .tracking(0.5)
                    Text(reactionTime)
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(Color.mustardYellow)
                        .contentTransition(.numericText())
                        .animation(.default, value: reactionTime)
                }
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, 6)
                .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: BuzzRadius.xxs)
                    .fill(player.teamColor.gradient)
                    .frame(width: 4)
                    .padding(.leading, 0)
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.lg2))
            }

            HStack(spacing: BuzzSpacing.sm) {
                validationButton(points: 10, scale: 0.88)
                validationButton(points: 20, scale: 0.94)
                validationButton(points: 30, scale: 1.0, highlighted: true)
            }

            Button(action: onReject) {
                Label("Refuser la réponse", systemImage: BuzzIcon.xmark)
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(Color.redSoft)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.redLeading.opacity(0.1), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.md).strokeBorder(Color.redLeading.opacity(0.35), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.top, BuzzSpacing.md)
        .padding(.bottom, 40)
        .background(Color.sheetBg, in: RoundedRectangle(cornerRadius: BuzzRadius.sheet))
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
                    .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
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
                in: RoundedRectangle(cornerRadius: BuzzRadius.md)
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
