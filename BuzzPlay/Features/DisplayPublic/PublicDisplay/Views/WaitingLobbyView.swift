//
//  WaitingLobbyView.swift
//  BuzzPlay
//
//  Salon d'attente affiché sur l'écran du buzzer tant que le Master n'a pas
//  lancé le premier jeu (PublicState == .waiting). Remplace l'ancien écran
//  "grand violet vide" (sablier + texte) par un vrai salon : identité du
//  joueur + son buzzer choisi en hero, roster animé qui se remplit, hint.
//
//  100% local — toutes les données arrivent déjà via MPC (player, knownPlayers).
//  Aucun nouveau message réseau.
//

import SwiftUI

struct WaitingLobbyView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    /// Texte de la pill du bas (contextuel : avant la partie / entre deux jeux).
    var hint: String = "Le Maître prépare la partie…"

    private var me: Player { playerGameVM.player }

    private var others: [Player] {
        playerGameVM.knownPlayers.filter { $0.id != me.id }
    }

    /// Couleur du buzzer choisie en boutique, sinon couleur d'équipe.
    private var buzzColor: GameColor { me.customBuzzColor ?? me.teamColor }

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            selfCard
            rosterSection
            Spacer(minLength: 0)
            waitingPill
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: others.count)
    }

    // MARK: - Self Card (identité + buzzer choisi)

    private var selfCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(buzzColor.gradient)
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(me.name.prefix(1)).uppercased())
                        .font(.nohemi(.title3, weight: .black))
                        .foregroundStyle(.white)
                )
                .shadow(color: buzzColor.color.opacity(0.5), radius: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(me.name)
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Chip du son buzzer choisi (valorise l'achat boutique).
                if let sound = me.customBuzzSound {
                    HStack(spacing: 5) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.nohemi(.caption2, weight: .bold))
                        Text(buzzSoundLabel(for: sound))
                            .font(.nohemi(.caption, weight: .semiBold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(buzzColor.color)
                    .padding(.horizontal, BuzzSpacing.sm)
                    .padding(.vertical, 4)
                    .background(buzzColor.color.opacity(0.16), in: Capsule())
                } else {
                    Text("C'est ton buzzer")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .textStyle(Typography.sectionTitle)
                .foregroundStyle(Color.greenGlow)
        }
        .padding(14)
        .background(
            buzzColor.color.opacity(0.16),
            in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(buzzColor.color.opacity(0.45), lineWidth: 1.5)
        )
    }

    // MARK: - Roster (qui est dans le salon)

    private var rosterSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(spacing: 6) {
                Text("DANS LE SALON")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.textMuted)
                Text("· \(playerGameVM.knownPlayers.count)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            if others.isEmpty {
                Text("En attente d'autres joueurs…")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, BuzzSpacing.md)
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                    spacing: BuzzSpacing.md
                ) {
                    ForEach(others) { player in
                        playerAvatar(player)
                            .transition(.scale(scale: 0.6).combined(with: .opacity))
                    }
                }
            }
        }
    }

    private func playerAvatar(_ player: Player) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill((player.customBuzzColor ?? player.teamColor).gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.subheadline, weight: .black))
                        .foregroundStyle(.white)
                )
            Text(player.name)
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Pulsing hint

    private var waitingPill: some View {
        PlayerPulsingPill(text: hint)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    let vm = PlayerGameViewModel(
        player: Player(name: "Léa", teamColor: .redGame, customBuzzColor: .purpleGame, customBuzzSound: "Mosquito"),
        mpc: MPCService(peerName: "Léa", role: .team)
    )
    vm.knownPlayers = [
        vm.player,
        Player(name: "Max", teamColor: .greenGame),
        Player(name: "Tom", teamColor: .blueGame),
        Player(name: "Iris", teamColor: .yellowGame),
        Player(name: "Sam", teamColor: .purpleGame),
    ]
    return ZStack {
        BackgroundAppView().ignoresSafeArea()
        WaitingLobbyView(playerGameVM: vm)
            .padding()
    }
}
