//
//  PostRoundLeaderboardView.swift
//  BuzzPlay
//

import SwiftUI

struct PostRoundLeaderboardView: View {
    let previousRanking: [Player]
    let currentRanking: [Player]
    // #B2 — sous-titre contextuel : "Le Maître prépare la suite…" en inter-manche,
    // "Quiz terminé" / "Blind Test terminé" en inter-jeu (même vue partout).
    var headline: String = "Le Maître prépare la suite…"

    @State private var displayedPlayers: [Player] = []
    @State private var showDeltas = false

    // #B1 — tri stable : à score égal, départage par nom (clé stable même à la reco où
    // l'UUID change). Sans ce tie-break, previousRanking et currentRanking pouvaient
    // s'ordonner différemment à scores égaux → fausse flèche ↑/↓ "perd une place".
    private func rankedByScore(_ players: [Player]) -> [Player] {
        players.sorted { a, b in
            a.score != b.score ? a.score > b.score : a.name < b.name
        }
    }

    var body: some View {
        // #15 — présenté en demi-sheet : le fond est fourni par `.presentationBackground`,
        // la révélation de la réponse reste visible au-dessus de la sheet.
        VStack(spacing: 0) {
            header
                .padding(.top, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.md)

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
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        // #D7/#D8 — une seule source d'animation pour éviter le conflit shape/contenu
        .animation(.buzzFade, value: showDeltas)
        .onAppear {
            // Étape 1 : affichage en ANCIEN ordre (avec les scores déjà mis à jour)
            let orderedByOld = rankedByScore(previousRanking)
                .compactMap { old in currentRanking.first(where: { $0.id == old.id }) }
            displayedPlayers = orderedByOld

            // Étape 2 : après 1s, animer vers le NOUVEL ordre via withAnimation explicite
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.76)) {
                    displayedPlayers = rankedByScore(currentRanking)
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
            // #E2/#B2 — sous-titre contextuel (inter-manche ou inter-jeu)
            Text(headline)
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(Color.textMuted)
        }
    }

    // MARK: - Helpers

    private func oldRankOf(_ player: Player) -> Int {
        let sorted = rankedByScore(previousRanking)
        return (sorted.firstIndex(where: { $0.id == player.id }) ?? 0) + 1
    }

    private func newRankOf(_ player: Player) -> Int {
        let sorted = rankedByScore(currentRanking)
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
        BuzzCountBadge("\(rank)",
                       diameter: 34, fontSize: 15,
                       fill: AnyShapeStyle(rankCircleColor),
                       textColor: rank <= 3 ? Color.sheetBg : .white)
    }

    private var playerAvatar: some View {
        BuzzCountBadge(String(player.name.prefix(1)).uppercased(),
                       diameter: 34, fontSize: 15,
                       fill: AnyShapeStyle(player.teamColor.gradient),
                       textColor: .white)
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
                // #R2 — norme pill : la capsule centre le texte mono-ligne par défaut
                // (+ .fixedSize via pillStyle) → plus de padding asymétrique à régler.
                Text("+\(scoreDelta)")
                    .font(.nohemi(.caption, weight: .extraBold))
                    .foregroundStyle(Color.greenButtonLeading)
                    .pillStyle(fill: Color.greenButtonLeading.opacity(0.15),
                               stroke: Color.greenButtonLeading.opacity(0.35),
                               compact: true)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            if rankDelta != 0 {
                let up = rankDelta > 0
                // symbole interpolé dans le Text → flèche alignée sur le chiffre.
                Text("\(Image(systemName: up ? "arrow.up" : "arrow.down")) \(abs(rankDelta))")
                    .font(.nohemi(.caption2, weight: .extraBold))
                    .foregroundStyle(up ? Color.greenButtonLeading : Color.redSoft)
                    .pillStyle(fill: (up ? Color.greenButtonLeading : Color.redSoft).opacity(0.12),
                               stroke: nil,
                               compact: true)
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

    // #B10 — fond neutre basé sur le rang, pas sur la teamColor du joueur
    // (évite la collision rouge/vert avec le feedback bonne/mauvaise réponse)
    private var rowBackground: AnyShapeStyle {
        switch rank {
        case 1: AnyShapeStyle(Color.amberWarm.opacity(0.10))
        case 2: AnyShapeStyle(Color.white.opacity(0.08))
        case 3: AnyShapeStyle(Color.burnOrange.opacity(0.08))
        default: AnyShapeStyle(Color.white.opacity(0.04))
        }
    }

    private var rowBorder: Color {
        switch rank {
        case 1: Color.amberWarm.opacity(0.30)
        case 2: .white.opacity(0.15)
        case 3: Color.burnOrange.opacity(0.22)
        default: .white.opacity(0.07)
        }
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
