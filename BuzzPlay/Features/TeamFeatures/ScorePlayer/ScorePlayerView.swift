//
//  ScorePlayerView.swift
//  BuzzPlay
//

import SwiftUI

struct ScorePlayerView: View {
    var teamGameVM: TeamGameViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var team: Team { teamGameVM.team }
    private var teamColor: Color { Color(team.teamColor.rawValue) }

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
            VStack(spacing: 20) {
                scoreHero
                playersCard
                if !teamGameVM.openGames.filter({ $0 != .score }).isEmpty {
                    nextGamesCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    // MARK: - iPad

    private var ipadLayout: some View {
        HStack(spacing: 24) {
            VStack(spacing: 20) {
                scoreHero
                playersCard
            }
            .frame(maxWidth: .infinity)

            if !teamGameVM.openGames.filter({ $0 != .score }).isEmpty {
                nextGamesCard
                    .frame(maxWidth: 320)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Score Hero

    private var scoreHero: some View {
        VStack(spacing: 20) {
            // Color accent bar
            RoundedRectangle(cornerRadius: 4)
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
                    Text(team.name)
                        .font(.nohemi(.title, weight: .extraBold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(team.score)")
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
                        .frame(width: team.score > 0 ? geo.size.width : 8, height: 8)
                        .animation(.spring(duration: 0.8, bounce: 0.2), value: team.score)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(teamColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(teamColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Players Card

    private var playersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("JOUEURS")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)

            let validPlayers = team.players.filter { !$0.name.isEmpty }
            if validPlayers.isEmpty {
                Text("Aucun joueur")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.25))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(validPlayers) { player in
                        HStack(spacing: 6) {
                            Text(String(player.name.prefix(1).uppercased()))
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(teamColor)
                                .frame(width: 22, height: 22)
                                .background(teamColor.opacity(0.15), in: Circle())
                            Text(player.name)
                                .font(.nohemi(.subheadline, weight: .semiBold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.06), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Next Games

    private var nextGamesCard: some View {
        let available = teamGameVM.openGames.filter { $0 != .score }
        return VStack(alignment: .leading, spacing: 12) {
            Text("JEUX DISPONIBLES")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)

            ForEach(available, id: \.self) { game in
                HStack(spacing: 12) {
                    Image(systemName: game.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(teamColor)
                        .frame(width: 36, height: 36)
                        .background(teamColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                    Text(game.gameTitle)
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#00C950"))
                            .frame(width: 5, height: 5)
                        Text("Ouvert")
                            .font(.nohemi(.caption2, weight: .bold))
                            .foregroundStyle(Color(hex: "#00C950"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#00C950").opacity(0.1), in: Capsule())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.07), lineWidth: 1))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))
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
    ScorePlayerView(
        teamGameVM: TeamGameViewModel(
            team: sampleTeams[0],
            mpc: MPCService(peerName: sampleTeams[0].name, role: .team)
        )
    )
}
