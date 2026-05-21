//
//  PlayerChooseGameView.swift
//  BuzzPlay
//

import SwiftUI

struct PlayerChooseGameView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    @EnvironmentObject var router: Router
    @Bindable var playerFlowVM: PlayerFlowViewModel

    private var otherPlayers: [Player] {
        playerGameVM.knownPlayers.filter { $0.id != playerGameVM.player.id }
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    selfCard
                    if !otherPlayers.isEmpty { othersSection }
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            VStack {
                Spacer()
                waitingPill
            }

            if !playerGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                playerCountBadge
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
        .onChange(of: playerGameVM.hasPartyStarted) { _, started in
            if started { router.push(.playerGameView) }
        }
    }

    // MARK: - Player count badge

    private var playerCountBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.greenLeading)
                .frame(width: 8, height: 8)
                .shadow(color: Color.greenLeading.opacity(0.7), radius: 4)
            Text("\(playerGameVM.knownPlayers.count) joueur\(playerGameVM.knownPlayers.count > 1 ? "s" : "")")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("EN ATTENTE DU MAÎTRE")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.40))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("La partie démarre dès\nque l'hôte lance.")
                .font(.nohemi(.title2, weight: .black))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(2)
        }
    }

    // MARK: - Self Card

    private var selfCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(playerGameVM.player.teamColor.gradient)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(String(playerGameVM.player.name.prefix(1)).uppercased())
                        .font(.nohemi(.title3, weight: .black))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(playerGameVM.player.name)
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("C'est toi")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.greenGlow)
        }
        .padding(14)
        .background(
            playerGameVM.player.teamColor.color.opacity(0.18),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(playerGameVM.player.teamColor.color.opacity(0.45), lineWidth: 1.5)
        )
    }

    // MARK: - Others Grid

    private var othersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("AUTRES JOUEURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.40))
                Text("· \(otherPlayers.count)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.40))
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4),
                spacing: 16
            ) {
                ForEach(otherPlayers) { player in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(player.teamColor.gradient)
                            .frame(width: 52, height: 52)
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
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Waiting Pill

    private var waitingPill: some View {
        PulsingPill()
            .padding(.bottom, 32)
    }
}

// MARK: - Pulsing Pill

private struct PulsingPill: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.mustardYellow)
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.2 : 0.8)
                .opacity(isPulsing ? 1 : 0.4)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPulsing)
            Text("Le Maître prépare la partie…")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.10), lineWidth: 1))
        .onAppear { isPulsing = true }
    }
}


#Preview {
    PlayerChooseGameView(
        playerGameVM: {
            let vm = PlayerGameViewModel(
                player: Player(name: "Léa", teamColor: .redGame),
                mpc: MPCService(peerName: "Léa", role: .team)
            )
            vm.knownPlayers = [
                Player(name: "Léa", teamColor: .redGame),
                Player(name: "Max", teamColor: .greenGame),
                Player(name: "Tom", teamColor: .blueGame),
                Player(name: "Iris", teamColor: .yellowGame),
                Player(name: "Sam", teamColor: .purpleGame),
            ]
            return vm
        }(),
        playerFlowVM: PlayerFlowViewModel()
    )
    .environmentObject(Router())
}
