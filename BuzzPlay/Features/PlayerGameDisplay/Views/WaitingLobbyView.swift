//
//  WaitingLobbyView.swift
//  BuzzPlay
//
//  Salon d'attente affiché sur l'écran du joueur tant qu'aucun jeu n'est lancé
//  (avant le premier jeu ET entre deux jeux — PublicState == .waiting,
//  currentBuzzerVM == nil côté PlayerGameView).
//
//  LOT B — refonte salon : plus de grosse card « C'est toi ». La liste des joueurs
//  présents (soi inclus, surligné) prend le dessus, + un mini-onboarding « Comment
//  jouer » et un bandeau Notes EXPLIQUÉ (le joueur comprend le bonus de bienvenue
//  qui s'affiche en toast — W1/W2).
//
//  100% local — tout arrive déjà via MPC (player, knownPlayers) ou du wallet local
//  (Notes). Aucun nouveau message réseau.
//

import SwiftUI

struct WaitingLobbyView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    /// Texte de la pill du bas (contextuel : avant la partie / entre deux jeux).
    var hint: String = "Le Maître prépare la partie…"

    private var me: Player { playerGameVM.player }

    /// Tous les joueurs du salon, MOI EN PREMIER, puis les autres dans l'ordre d'arrivée.
    private var lobbyPlayers: [Player] {
        let others = playerGameVM.knownPlayers.filter { $0.id != me.id }
        return [me] + others
    }

    private var othersCount: Int { max(playerGameVM.knownPlayers.count - 1, 0) }

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: BuzzSpacing.lg) {
                    notesBanner
                    rosterSection
                    onboardingSection
                }
            }
            waitingPill
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: playerGameVM.knownPlayers.count)
    }

    // MARK: - Bandeau Notes (W1/W2 — le joueur comprend ses Notes)

    private var notesBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "dollarsign.bank.building.fill")
                .font(.nohemi(.title3, weight: .bold))
                .foregroundStyle(Color.mustardYellow)
                .frame(width: 48, height: 48)
                .background(Color.mustardYellow.opacity(0.14), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(playerGameVM.notesWallet.balance)")
                        .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
                        .monospacedDigit()
                        .foregroundStyle(Color.mustardYellow)
                    Text("Notes")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(Color.mustardYellow.opacity(0.9))
                }
                Text("Offertes pour jouer — dépense-les en pouvoirs pendant la partie.")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.mustardYellow.opacity(0.10), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(Color.mustardYellow.opacity(0.30), lineWidth: 1)
        )
    }

    // MARK: - Liste des joueurs (soi inclus, surligné)

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

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                spacing: BuzzSpacing.md
            ) {
                ForEach(lobbyPlayers) { player in
                    playerAvatar(player, isSelf: player.id == me.id)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }

            if othersCount == 0 {
                Text("En attente d'autres joueurs…")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, BuzzSpacing.xs)
            }
        }
    }

    private func playerAvatar(_ player: Player, isSelf: Bool) -> some View {
        let color = player.customBuzzColor ?? player.teamColor
        return VStack(spacing: 6) {
            Circle()
                .fill(color.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.subheadline, weight: .black))
                        .foregroundStyle(.white)
                )
                .overlay(
                    Circle().strokeBorder(.white.opacity(isSelf ? 0.9 : 0), lineWidth: 2)
                )
                .shadow(color: isSelf ? color.color.opacity(0.5) : .clear, radius: 8)

            Text(isSelf ? "toi" : player.name)
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(isSelf ? .white : .white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Mini-onboarding « Comment jouer »

    private var onboardingSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(spacing: 6) {
                Text("COMMENT JOUER")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.textMuted)
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            onboardingRow(
                icon: "hand.tap.fill",
                tint: Color.buzzHotPink,
                title: "Buzze en premier",
                detail: "Le plus rapide à appuyer répond — tiens-toi prêt !"
            )
            onboardingRow(
                icon: "gift.fill",
                tint: Color.purpleLeading,
                title: "Lance des pouvoirs",
                detail: "Bloque un adversaire, double tes points, protège-toi avec un bouclier."
            )
            onboardingRow(
                icon: "dollarsign.bank.building.fill",
                tint: Color.mustardYellow,
                title: "Tes Notes servent à ça",
                detail: "Les pouvoirs coûtent des Notes. Tu en reçois en arrivant et tu en gagnes à chaque partie."
            )
        }
    }

    private func onboardingRow(icon: String, tint: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.nohemi(.callout, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: BuzzRadius.md))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.nohemi(.caption, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
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
