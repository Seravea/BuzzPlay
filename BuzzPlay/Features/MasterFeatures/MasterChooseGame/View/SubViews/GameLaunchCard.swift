//
//  GameLaunchCard.swift
//  BuzzPlay
//
//  Carte de lancement d'un mode de jeu (Quiz / BlindTest) dans le hub Master :
//  icône + titre + bouton « Lancer » avec état (disponible / joueurs pas prêts / terminé).
//  Extrait de MasterChooseGameView. La navigation reste au parent via onLaunch.
//

import SwiftUI

struct GameLaunchCard: View {
    let game: GameType
    let gradient: LinearGradient
    @Bindable var vm: MasterChooseGameViewModel
    /// Déclenché au tap « Lancer » — le parent garde le routing (vm.trackAndLaunch + router.push).
    let onLaunch: () -> Void

    var body: some View {
        let isAvailable: Bool = game == .quiz
            ? vm.isQuizCardAvailable
            : vm.isBlindTestCardAvailable
        let allReady = vm.allPlayersReady
        let readyCount = vm.readyPlayersCount
        // #E1 — dénominateur = total enregistrés (inclut un joueur déconnecté en reconnexion)
        let totalCount = vm.totalPlayersCount

        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: game.iconName)
                    .textStyle(Typography.sectionTitle)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(gradient.opacity(isAvailable ? 0.25 : 0.10), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

                Text(game.gameTitle)
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(isAvailable ? .white : Color.textDim)
                    .lineLimit(1)
            }
            .padding(.top, 18)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 1)

            Button {
                onLaunch()
            } label: {
                HStack(spacing: 6) {
                    if !isAvailable {
                        Image(systemName: "checkmark")
                            .textStyle(Typography.captionEM)
                        Text("Terminé")
                            .font(.nohemi(.subheadline, weight: .bold))
                    } else if !allReady {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(.white.opacity(0.6))
                        Text("\(readyCount)/\(totalCount) prêts…")
                            .font(.nohemi(.subheadline, weight: .bold))
                    } else {
                        Image(systemName: game.iconName)
                            .textStyle(Typography.captionEM)
                        Text("Lancer")
                            .font(.nohemi(.subheadline, weight: .bold))
                    }
                }
                .foregroundStyle((isAvailable && allReady) ? .white : Color.textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    (isAvailable && allReady)
                        ? AnyShapeStyle(gradient)
                        : AnyShapeStyle(Color.white.opacity(0.06)),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isAvailable || !allReady)
            .padding(.horizontal, BuzzSpacing.md)
            .padding(.vertical, 10)
        }
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.xl)
                .strokeBorder(.white.opacity(isAvailable ? 0.10 : 0.04), lineWidth: 1)
        )
        .opacity(isAvailable ? 1 : 0.55)
    }
}
