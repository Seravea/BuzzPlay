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
            HStack(alignment: .firstTextBaseline, spacing: BuzzSpacing.sm) {
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
