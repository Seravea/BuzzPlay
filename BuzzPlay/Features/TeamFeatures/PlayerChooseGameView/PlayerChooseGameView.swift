//
//  PlayerChooseGameView.swift
//  BuzzPlay
//

import SwiftUI

struct PlayerChooseGameView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    @EnvironmentObject var router: Router
    @Bindable var playerFlowVM: PlayerFlowViewModel
    @Environment(\.scenePhase) private var scenePhase

    private var otherPlayers: [Player] {
        playerGameVM.knownPlayers.filter { $0.id != playerGameVM.player.id }
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: BuzzSpacing.xl) {
                    headerSection
                    selfCard
                    buzzerHintCard
                    if !otherPlayers.isEmpty { othersSection }
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.lg)
            }

            VStack {
                Spacer()
                waitingPill
            }

            if !playerGameVM.isConnectedToMaster {
                if playerGameVM.hasEverConnectedToMaster {
                    ConnectionLostOverlay()
                } else {
                    WaitingForMasterOverlay()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                playerCountBadge
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
        .onAppear {
            // #rejoin — si la partie a déjà démarré au moment où la vue apparaît
            // (reconnexion/kill : masterStartedParty arrivé avant le montage de la vue),
            // .onChange ne se déclenchera pas → on route ici.
            if playerGameVM.hasPartyStarted { router.push(.playerGameView) }
        }
        .onChange(of: playerGameVM.hasPartyStarted) { _, started in
            if started { router.push(.playerGameView) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { playerGameVM.handleSceneWillForeground() }
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
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BuzzSpacing.xs) {
            Text("EN ATTENTE DU MAÎTRE")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color.textMuted)
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
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .textStyle(Typography.sectionTitle)
                .foregroundStyle(Color.greenGlow)
        }
        .padding(14)
        .background(
            playerGameVM.player.teamColor.color.opacity(0.18),
            in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(playerGameVM.player.teamColor.color.opacity(0.45), lineWidth: 1.5)
        )
    }

    // MARK: - Buzzer Hint Card

    private var buzzerHintCard: some View {
        HStack(spacing: BuzzSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.buzzHotPink.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "hand.point.up.left.fill")
                    .textStyle(Typography.sectionTitle)
                    .foregroundStyle(Color.buzzHotPink)
            }

            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text("C'est un jeu de buzzer !")
                    .font(.nohemi(.subheadline, weight: .extraBold))
                    .foregroundStyle(.white)
                Text("Appuie le plus vite possible\ndès que tu as la réponse.")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(BuzzSpacing.lg)
        .background(Color.buzzHotPink.opacity(0.07), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg2).strokeBorder(Color.buzzHotPink.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Others Grid

    private var othersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("AUTRES JOUEURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.textMuted)
                Text("· \(otherPlayers.count)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4),
                spacing: BuzzSpacing.lg
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
            .padding(.bottom, BuzzSpacing.xxxl)
    }
}

// MARK: - Pulsing Pill

private struct PulsingPill: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Circle()
                .fill(Color.mustardYellow)
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.2 : 0.8)
                .opacity(isPulsing ? 1 : 0.4)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPulsing)
            Text("Le Maître prépare la partie…")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.textSoft)
        }
        .padding(.horizontal, BuzzSpacing.lg)
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
