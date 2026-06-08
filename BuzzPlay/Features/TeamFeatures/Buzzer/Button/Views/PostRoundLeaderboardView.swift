//
//  PostRoundLeaderboardView.swift
//  BuzzPlay
//

import SwiftUI

struct PostRoundLeaderboardView: View {
    let previousRanking: [Player]
    let currentRanking: [Player]

    @State private var displayedPlayers: [Player] = []
    @State private var showDeltas = false

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.lg)

                ScrollView() {
                    VStack(spacing: 10) {
                        ForEach(Array(displayedPlayers.enumerated()), id: \.element.id) { index, player in
                            let oldScore = previousRanking.first(where: { $0.id == player.id })?.score ?? player.score
                            let oldRank  = oldRankOf(player)
                            let newRank  = newRankOf(player)
                            PostRoundRow(
                                rank: index + 1,
                                player: player,
                                scoreDelta: showDeltas ? (player.score - oldScore) : 0,
                                rankDelta: showDeltas ? (oldRank - newRank) : 0,
                                showDelta: showDeltas
                            )
                        }
                    }
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.xxxl)
                }
            }
        }
        .animation(.spring(response: 0.60, dampingFraction: 0.76), value: displayedPlayers.map(\.id))
        .animation(.buzzFade, value: showDeltas)
        .onAppear {
            // Étape 1 : affichage en ANCIEN ordre (avec les scores déjà mis à jour)
            let orderedByOld = previousRanking
                .sorted { $0.score > $1.score }
                .compactMap { old in currentRanking.first(where: { $0.id == old.id }) }
            displayedPlayers = orderedByOld

            // Étape 2 : après 1s, animer vers le NOUVEL ordre
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.76)) {
                    displayedPlayers = currentRanking.sorted { $0.score > $1.score }
                }
                withAnimation(.buzzEase.delay(0.45)) {
                    showDeltas = true
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: BuzzSpacing.xs) {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: "trophy.fill")
                    .textStyle(Typography.cardTitleBold)
                    .foregroundStyle(Color.mustardYellow)
                Text("CLASSEMENT")
                    .font(.nohemi(.headline, weight: .black))
                    .tracking(2)
                    .foregroundStyle(.white)
            }
            Text("Le Maître prépare la prochaine manche…")
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(.white.opacity(0.40))
        }
    }

    // MARK: - Helpers

    private func oldRankOf(_ player: Player) -> Int {
        let sorted = previousRanking.sorted { $0.score > $1.score }
        return (sorted.firstIndex(where: { $0.id == player.id }) ?? 0) + 1
    }

    private func newRankOf(_ player: Player) -> Int {
        let sorted = currentRanking.sorted { $0.score > $1.score }
        return (sorted.firstIndex(where: { $0.id == player.id }) ?? 0) + 1
    }
}

// MARK: - Row

private struct PostRoundRow: View {
    let rank: Int
    let player: Player
    let scoreDelta: Int
    let rankDelta: Int
    let showDelta: Bool

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            rankBadge
            playerAvatar
            nameAndScore
            Spacer()
            if showDelta { deltaBadges }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg)
                .strokeBorder(rowBorder, lineWidth: 1)
        )
    }

    private var rankBadge: some View {
        ZStack {
            Circle()
                .fill(rankCircleColor)
                .frame(width: 34, height: 34)
            Text("\(rank)")
                .font(.nohemi(.subheadline, weight: .black))
                .foregroundStyle(rank <= 3 ? Color.sheetBg : .white)
        }
    }

    private var playerAvatar: some View {
        Circle()
            .fill(player.teamColor.gradient)
            .frame(width: 34, height: 34)
            .overlay(
                Text(String(player.name.prefix(1)).uppercased())
                    .font(.nohemi(.subheadline, weight: .black))
                    .foregroundStyle(.white)
            )
    }

    private var nameAndScore: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(player.name)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text("\(player.score) pts")
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(.white.opacity(0.50))
                .contentTransition(.numericText())
        }
    }

    @ViewBuilder
    private var deltaBadges: some View {
        HStack(spacing: 6) {
            if scoreDelta > 0 {
                Text("+\(scoreDelta)")
                    .font(.nohemi(.caption, weight: .extraBold))
                    .foregroundStyle(Color.greenButtonLeading)
                    .padding(.horizontal, BuzzSpacing.sm)
                    .padding(.vertical, 3)
                    .background(Color.greenButtonLeading.opacity(0.15), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.greenButtonLeading.opacity(0.35), lineWidth: 1))
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            if rankDelta != 0 {
                let up = rankDelta > 0
                HStack(spacing: 2) {
                    Image(systemName: up ? "arrow.up" : "arrow.down")
                        .textStyle(Typography.micro)
                    Text("\(abs(rankDelta))")
                        .font(.nohemi(.caption2, weight: .extraBold))
                }
                .foregroundStyle(up ? Color.greenButtonLeading : Color.redSoft)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    (up ? Color.greenButtonLeading : Color.redSoft).opacity(0.12),
                    in: Capsule()
                )
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
    }

    // MARK: - Style helpers

    private var rankCircleColor: Color {
        switch rank {
        case 1: Color.amberWarm
        case 2: Color.white
        case 3: Color.burnOrange
        default: .white.opacity(0.12)
        }
    }

    private var rowBackground: AnyShapeStyle {
        rank <= 3
            ? AnyShapeStyle(player.teamColor.color.opacity(0.13))
            : AnyShapeStyle(Color.white.opacity(0.05))
    }

    private var rowBorder: Color {
        rank <= 3 ? player.teamColor.color.opacity(0.28) : .white.opacity(0.07)
    }
}

#Preview {
    let prev = [
        Player(name: "Léa",  teamColor: .redGame,    score: 60),
        Player(name: "Max",  teamColor: .greenGame,  score: 40),
        Player(name: "Tom",  teamColor: .blueGame,   score: 30),
        Player(name: "Iris", teamColor: .yellowGame, score: 10),
    ]
    let curr = [
        Player(name: "Léa",  teamColor: .redGame,    score: 60),
        Player(name: "Max",  teamColor: .greenGame,  score: 70),
        Player(name: "Tom",  teamColor: .blueGame,   score: 30),
        Player(name: "Iris", teamColor: .yellowGame, score: 10),
    ]
    return PostRoundLeaderboardView(previousRanking: prev, currentRanking: curr)
}
