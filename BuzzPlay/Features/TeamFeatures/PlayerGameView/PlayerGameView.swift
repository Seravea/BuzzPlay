//
//  PlayerGameView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Hub permanent du joueur

struct PlayerGameView: View {
    @Bindable var playerGameVM: PlayerGameViewModel
    @Bindable var playerFlowVM: PlayerFlowViewModel
    @EnvironmentObject var router: Router

    @State private var currentGameType: GameType = .quiz
    @State private var showGameAnnounce = false
    @State private var showInterGameScore = false
    @State private var showPodium = false

    var body: some View {
        ZStack {
            BuzzerPlayerView(playerGameVM: playerGameVM, gameType: currentGameType)

            if playerGameVM.currentBuzzerVM == nil {
                waitingOverlay
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showGameAnnounce) {
            GameAnnounceSheet(game: currentGameType)
        }
        .sheet(isPresented: $showInterGameScore) {
            InterGameScoreSheet(players: playerGameVM.knownPlayers)
        }
        .sheet(isPresented: $showPodium) {
            PlayerPodiumSheet(
                players: playerGameVM.knownPlayers,
                currentPlayer: playerGameVM.player,
                onQuit: { router.popToRoot() },
                onReplay: { router.path.removeLast() }
            )
        }
        .onAppear {
            // Cas kill app + relaunch : pendingGameInvite déjà set avant l'apparition de la vue
            if let invite = playerGameVM.pendingGameInvite {
                handleGameInvite(invite)
            }
        }
        .onChange(of: playerGameVM.pendingGameInvite) { _, invite in
            guard let invite else { return }
            handleGameInvite(invite)
        }
        .onChange(of: playerGameVM.isGameComplete) { _, complete in
            guard complete else { return }
            showInterGameScore = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showPodium = true
            }
        }
        .onChange(of: playerGameVM.shouldReturnToLobby) { _, should in
            guard should else { return }
            playerGameVM.shouldReturnToLobby = false
            showPodium = false
            showInterGameScore = false
            router.path.removeLast()
        }
    }

    // MARK: - Waiting overlay

    private var waitingOverlay: some View {
        VStack {
            Spacer()
            PlayerPulsingPill(text: "En attente du prochain jeu…")
                .padding(.bottom, 48)
        }
    }

    // MARK: - Game invite handling

    private func handleGameInvite(_ game: GameType) {
        playerGameVM.pendingGameInvite = nil
        if game == .score {
            if !playerGameVM.isGameComplete {
                showInterGameScore = true
                // #C4/#B7 — signale au Master que le Player a reçu le score inter-manche
                // et est prêt à recevoir la prochaine invitation
                playerGameVM.sendPlayerReady()
            }
        } else {
            currentGameType = game
            // #C7 — si un BuzzerVM existe déjà (reconnexion mid-game), sync l'état
            // au lieu de recréer pour ne pas perdre le lock/unlock courant
            if playerGameVM.currentBuzzerVM == nil {
                playerGameVM.currentBuzzerVM = playerFlowVM.makeBuzzerViewModel(
                    for: game == .quiz ? .quiz : .blindTest
                )
            }
            // Re-confirme la présence au Master (#B7 : BuzzerPlayerView déjà à l'écran → onAppear ne refire pas)
            playerGameVM.sendPlayerReady()
            if showInterGameScore {
                showInterGameScore = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showGameAnnounce = true
                }
            } else {
                showGameAnnounce = true
            }
        }
    }
}

// MARK: - Pulsing pill réutilisable

struct PlayerPulsingPill: View {
    let text: String
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Circle()
                .fill(Color.mustardYellow)
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.2 : 0.8)
                .opacity(isPulsing ? 1 : 0.4)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isPulsing)
            Text(text)
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

// MARK: - Sheet 1 : Annonce du jeu

private struct GameAnnounceSheet: View {
    let game: GameType
    @Environment(\.dismiss) private var dismiss

    @State private var countdown = 3
    @State private var progress: CGFloat = 1.0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xxl)

            VStack(spacing: BuzzSpacing.xl) {
                HStack(spacing: 14) {
                    Image(systemName: game.iconName)
                        .textStyle(Typography.sectionTitle)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

                    VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                        Text("Le Maître lance")
                            .font(.nohemi(.subheadline, weight: .regular))
                            .foregroundStyle(Color.textSecondary)
                        Text(game.gameTitle)
                            .font(.nohemi(.title2, weight: .extraBold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.1), lineWidth: 3)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        Text("\(countdown)")
                            .font(.nohemi(.body, weight: .extraBold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 44, height: 44)
                }

                Text("Prépare-toi à buzzer !")
                    .font(.nohemi(.callout, weight: .semiBold))
                    .foregroundStyle(Color.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, BuzzSpacing.xl)

            Spacer()
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.sheetBg)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.sheetBg)
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private func startCountdown() {
        countdown = 3
        progress = 1.0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown <= 1 {
                t.invalidate()
                dismiss()
            } else {
                countdown -= 1
                progress = CGFloat(countdown - 1) / 3.0
            }
        }
    }
}

// MARK: - Sheet 2 : Score inter-jeux

private struct InterGameScoreSheet: View {
    let players: [Player]

    private var sortedPlayers: [Player] {
        players.sorted { $0.score > $1.score }
    }
    private var maxScore: Int {
        sortedPlayers.first?.score ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)

            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text("SCORES")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.textMuted)
                Text("Classement actuel")
                    .font(.nohemi(.title2, weight: .extraBold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.lg)

            Divider().overlay(Color.white.opacity(0.08))

            ScrollView {
                VStack(spacing: BuzzSpacing.sm) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        scoreRow(rank: index + 1, player: player)
                    }
                }
                .padding(BuzzSpacing.lg)
            }

            PlayerPulsingPill(text: "En attente du prochain jeu…")
                .padding(.vertical, BuzzSpacing.lg)
        }
        .foregroundStyle(.white)
        .background(Color.sheetBg)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.sheetBg)
        .interactiveDismissDisabled()
    }

    private func scoreRow(rank: Int, player: Player) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            Text("#\(rank)")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .frame(width: 28, alignment: .leading)

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: 38, height: 38)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.callout, weight: .black))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text(player.name)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08)).frame(height: 4)
                        let ratio = maxScore > 0 ? CGFloat(player.score) / CGFloat(maxScore) : 0
                        Capsule()
                            .fill(player.teamColor.color.opacity(0.85))
                            .frame(width: geo.size.width * ratio, height: 4)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            Text("\(player.score) pts")
                .font(.nohemi(.callout, weight: .extraBold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, BuzzSpacing.md)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.md).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Sheet 3 : Podium final

private struct PlayerPodiumSheet: View {
    let players: [Player]
    let currentPlayer: Player
    let onQuit: () -> Void
    let onReplay: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var sorted: [Player] {
        players.sorted { $0.score > $1.score }
    }

    private func rank(of player: Player) -> Int? {
        sorted.firstIndex(where: { $0.id == player.id }).map { $0 + 1 }
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: BuzzSpacing.xs) {
                    Text("PARTIE TERMINÉE")
                        .font(.nohemi(.caption2, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Color.textMuted)
                    Text("Classement final")
                        .font(.nohemi(.title, weight: .extraBold))
                        .foregroundStyle(.white)
                }
                .padding(.top, BuzzSpacing.xxxl)
                .padding(.bottom, 28)

                // My rank highlight
                if let myRank = rank(of: currentPlayer) {
                    myRankCard(rank: myRank, player: currentPlayer)
                        .padding(.horizontal, BuzzSpacing.xl)
                        .padding(.bottom, BuzzSpacing.xl)
                }

                Divider().overlay(Color.white.opacity(0.08)).padding(.horizontal, BuzzSpacing.xl)

                // Full ranking
                ScrollView {
                    VStack(spacing: BuzzSpacing.sm) {
                        ForEach(Array(sorted.enumerated()), id: \.element.id) { index, player in
                            podiumRow(rank: index + 1, player: player, isSelf: player.id == currentPlayer.id)
                        }
                    }
                    .padding(BuzzSpacing.xl)
                }

                // Actions
                HStack(spacing: 10) {
                    Button(action: { dismiss(); onQuit() }) {
                        Text("Quitter")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
                    }
                    .buttonStyle(.plain)

                    Button(action: { dismiss(); onReplay() }) {
                        Text("Rejouer")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(colors: [Color.purpleLeading, Color.purpleTrailing],
                                               startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, 40)
            }
        }
        .foregroundStyle(.white)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
    }

    private func myRankCard(rank: Int, player: Player) -> some View {
        HStack(spacing: 14) {
            Text(rankEmoji(rank))
                .textStyle(Typography.screenTitle)

            VStack(alignment: .leading, spacing: 2) {
                Text("Ta position")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                Text("\(rank)\(rankSuffix(rank)) place")
                    .font(.nohemi(.title3, weight: .extraBold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(player.score)")
                    .font(.nohemi(.title2, weight: .black))
                    .foregroundStyle(player.teamColor.color)
                Text("points")
                    .font(.nohemi(.caption2, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(BuzzSpacing.lg)
        .background(player.teamColor.color.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(player.teamColor.color.opacity(0.35), lineWidth: 1.5)
        )
    }

    private func podiumRow(rank: Int, player: Player, isSelf: Bool) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            Text(rankEmoji(rank))
                .textStyle(Typography.title3)
                .frame(width: 32)

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.callout, weight: .black))
                        .foregroundStyle(.white)
                )

            Text(player.name)
                .font(.nohemi(.subheadline, weight: isSelf ? .extraBold : .bold))
                .foregroundStyle(isSelf ? .white : .white.opacity(0.85))

            if isSelf {
                Text("(toi)")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            Text("\(player.score) pts")
                .font(.nohemi(.callout, weight: .extraBold))
                .foregroundStyle(isSelf ? player.teamColor.color : Color.textSoft)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isSelf ? player.teamColor.color.opacity(0.08) : .white.opacity(0.04), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.md)
                .strokeBorder(isSelf ? player.teamColor.color.opacity(0.25) : .white.opacity(0.06), lineWidth: 1)
        )
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }

    private func rankSuffix(_ rank: Int) -> String {
        rank == 1 ? "ère" : "ème"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlayerGameView(
            playerGameVM: {
                let vm = PlayerGameViewModel(
                    player: Player(name: "Léa", teamColor: .redGame),
                    mpc: MPCService(peerName: "Léa", role: .team)
                )
                vm.knownPlayers = [
                    Player(name: "Léa", teamColor: .redGame, score: 240),
                    Player(name: "Max", teamColor: .greenGame, score: 180),
                    Player(name: "Tom", teamColor: .blueGame, score: 90),
                ]
                return vm
            }(),
            playerFlowVM: PlayerFlowViewModel()
        )
        .environmentObject(Router())
    }
}
