//
//  ScorePlayerView.swift
//  BuzzPlay
//

import SwiftUI

struct ScorePlayerView: View {
    var playerGameVM: PlayerGameViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var currentPlayer: Player { playerGameVM.player }
    private var teamColor: Color { Color(currentPlayer.teamColor.rawValue) }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            if sizeClass == .regular {
                ipadLayout
            } else {
                iphoneLayout
            }
        }
        .foregroundStyle(.white)
    }

    // MARK: - iPhone

    private var iphoneLayout: some View {
        ScrollView {
            VStack(spacing: BuzzSpacing.xl) {
                scoreHero
                playersCard
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.top, BuzzSpacing.xl)
        }
    }

    // MARK: - iPad

    private var ipadLayout: some View {
        VStack(spacing: BuzzSpacing.xl) {
            scoreHero
            playersCard
        }
        .padding(.horizontal, BuzzSpacing.xxxl)
        .padding(.top, BuzzSpacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Score Hero

    private var scoreHero: some View {
        VStack(spacing: BuzzSpacing.xl) {
            // Color accent bar
            RoundedRectangle(cornerRadius: BuzzRadius.xxs)
                .fill(
                    LinearGradient(
                        colors: [teamColor, teamColor.opacity(0)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(height: 3)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TON SCORE")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(0.8)
                    Text(currentPlayer.name)
                        .font(.nohemi(.title, weight: .extraBold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(currentPlayer.score)")
                        .font(.custom("Nohemi-Black", size: 56))
                        .foregroundStyle(teamColor)
                    Text("points")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.08))
                        .frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [teamColor, teamColor.opacity(0.6)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: currentPlayer.score > 0 ? geo.size.width : 8, height: 8)
                        .animation(.spring(duration: 0.8, bounce: 0.2), value: currentPlayer.score)
                }
            }
            .frame(height: 8)
        }
        .padding(BuzzSpacing.xl)
        .background(teamColor.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.xl)
                .strokeBorder(teamColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Players Card

    private var playersCard: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text("JOUEURS")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)

//            if validPlayers.isEmpty {
//                Text("Aucun joueur")
//                    .font(.nohemi(.subheadline, weight: .regular))
//                    .foregroundStyle(.white.opacity(0.25))
//            } else {
                FlowLayout(spacing: BuzzSpacing.sm) {
//                    ForEach(validPlayers) { player in
                        HStack(spacing: 6) {
                            Text(String(currentPlayer.name.prefix(1).uppercased()))
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(teamColor)
                                .frame(width: 22, height: 22)
                                .background(teamColor.opacity(0.15), in: Circle())
                            Text(currentPlayer.name)
                                .font(.nohemi(.subheadline, weight: .semiBold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, BuzzSpacing.md)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.06), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1))
                    }
//                }
//            }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg2).strokeBorder(.white.opacity(0.08), lineWidth: 1))
        }
        
    }

}

// MARK: - FlowLayout helper

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            rowWidth += size.width + spacing
        }
        return rows
    }
}

#Preview {
    let samplePlayer = Player(name: "Team 1", teamColor: .greenGame, score: 240)
    return ScorePlayerView(
        playerGameVM: PlayerGameViewModel(
            player: samplePlayer,
            mpc: MPCService(peerName: samplePlayer.name, role: .team)
        )
    )
}
