//
//  PlayerChooseGameView.swift
//  BuzzPlay
//

import SwiftUI

struct PlayerChooseGameView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    @EnvironmentObject var router: Router
    @Bindable var teamFlowVM: TeamFlowViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let accentColor = Color.white

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    teamHeader
                    gamesSection
                }
                .padding(.horizontal, sizeClass == .regular ? 0 : 20)
                .padding(.top, 20)
                .frame(maxWidth: sizeClass == .regular ? 700 : .infinity)
                .frame(maxWidth: .infinity)
            }

            if !teamGameVM.isConnectedToMaster {
                ConnectionLostOverlay()
            }

            // Invite du Master
            if let game = teamGameVM.pendingGameInvite {
                GameInviteOverlay(
                    game: game,
                    accentColor: accentColor,
                    onJoin: { joinGame(game) },
                    onDismiss: { teamGameVM.pendingGameInvite = nil }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.45, bounce: 0.05), value: teamGameVM.pendingGameInvite != nil)
        .navigationBarBackButtonHidden()
    }

    // MARK: - Team Header

    private var teamHeader: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(accentColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(teamGameVM.team.name)
                    .font(.nohemi(.title2, weight: .extraBold))
                    .foregroundStyle(.white)
                let playerNames = teamGameVM.team.players.map(\.name).filter { !$0.isEmpty }.joined(separator: " · ")
                if !playerNames.isEmpty {
                    Text(playerNames)
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(teamGameVM.team.score)")
                    .font(.nohemi(.title2, weight: .extraBold))
                    .foregroundStyle(accentColor)
                Text("points")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(accentColor.opacity(0.35), lineWidth: 1.5)
        )
    }

    // MARK: - Games Grid

    @ViewBuilder
    private var gamesSection: some View {
        if sizeClass == .regular {
            HStack(spacing: 16) {
                ForEach(GameType.allCases, id: \.self) { game in
                    gameCard(game)
                }
            }
        } else {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    gameCard(.quiz)
                    gameCard(.blindTest)
                }
                scoreRow
            }
        }
    }

    // MARK: - Vertical Game Card (Quiz / BlindTest / iPad Score)

    @ViewBuilder
    private func gameCard(_ game: GameType) -> some View {
        let isOpen = teamGameVM.gameIsAvalaible(game)
        Button {
            if isOpen { joinGame(game) }
        } label: {
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    statusBadge(isOpen: isOpen)
                }

                Image(systemName: game.iconName)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(isOpen ? accentColor : .white.opacity(0.25))
                    .frame(width: 60, height: 60)
                    .background(
                        isOpen ? accentColor.opacity(0.15) : .white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 16)
                    )

                Text(game.gameTitle)
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(isOpen ? .white : .white.opacity(0.3))
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(
                isOpen ? accentColor.opacity(0.08) : .white.opacity(0.04),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isOpen ? accentColor.opacity(0.4) : .white.opacity(0.07),
                        lineWidth: isOpen ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isOpen)
    }

    // MARK: - Horizontal Score Row (iPhone only)

    private var scoreRow: some View {
        let isOpen = teamGameVM.gameIsAvalaible(.score)
        return Button {
            if isOpen { joinGame(.score) }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: GameType.score.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isOpen ? accentColor : .white.opacity(0.25))
                    .frame(width: 46, height: 46)
                    .background(
                        isOpen ? accentColor.opacity(0.15) : .white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 12)
                    )

                Text("Score")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(isOpen ? .white : .white.opacity(0.3))

                Spacer()

                statusBadge(isOpen: isOpen)

                if isOpen {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                isOpen ? accentColor.opacity(0.08) : .white.opacity(0.04),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isOpen ? accentColor.opacity(0.4) : .white.opacity(0.07),
                        lineWidth: isOpen ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isOpen)
    }

    // MARK: - Join Game (partagé entre tap carte et auto-nav invite)

    private func joinGame(_ game: GameType) {
        teamGameVM.pendingGameInvite = nil
        if game != .score {
            teamGameVM.currentBuzzerVM = teamFlowVM.makeBuzzerViewModel(
                for: game == .quiz ? .quiz : .blindTest
            )
        }
        router.push(game.destinationPlayer)
    }

    // MARK: - Shared Badge

    private func statusBadge(isOpen: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isOpen ? .white.opacity(0.9) : .white.opacity(0.2))
                .frame(width: 5, height: 5)
            Text(isOpen ? "Ouvert" : "Fermé")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(isOpen ? .white.opacity(0.9) : .white.opacity(0.35))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            isOpen ? .white.opacity(0.12) : .white.opacity(0.05),
            in: Capsule()
        )
    }
}

// MARK: - Game Invite Overlay

private struct GameInviteOverlay: View {
    let game: GameType
    let accentColor: Color
    let onJoin: () -> Void
    let onDismiss: () -> Void

    @State private var countdown = 3
    @State private var timer: Timer? = nil
    @State private var progress: CGFloat = 1.0

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                // Handle
                RoundedRectangle(cornerRadius: 99)
                    .fill(.white.opacity(0.2))
                    .frame(width: 36, height: 4)

                // Icon + titre
                HStack(spacing: 14) {
                    Image(systemName: game.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(accentColor)
                        .frame(width: 52, height: 52)
                        .background(accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Le Master lance")
                            .font(.nohemi(.subheadline, weight: .regular))
                            .foregroundStyle(.white.opacity(0.55))
                        Text(game.gameTitle)
                            .font(.nohemi(.title2, weight: .extraBold))
                            .foregroundStyle(.white)
                    }
                    Spacer()

                    // Countdown circle
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.1), lineWidth: 3)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        Text("\(countdown)")
                            .font(.nohemi(.body, weight: .extraBold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 44, height: 44)
                }

                // Boutons
                HStack(spacing: 10) {
                    Button(action: onDismiss) {
                        Text("Plus tard")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    Button(action: onJoin) {
                        Text("Rejoindre !")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.7)],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .shadow(color: accentColor.opacity(0.4), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 36)
            .background(Color(hex: "#1A0535"), in: RoundedRectangle(cornerRadius: 28))
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private func startCountdown() {
        progress = 1.0
        countdown = 3
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown <= 1 {
                t.invalidate()
                onJoin()
            } else {
                countdown -= 1
                progress = CGFloat(countdown - 1) / 3.0
            }
        }
    }
}

#Preview {
    PlayerChooseGameView(
        teamGameVM: TeamGameViewModel(
            team: Team(name: "L'équipe des nul", teamColor: .blueGame),
            mpc: MPCService(peerName: "l'équipe", role: .team)
        ),
        teamFlowVM: TeamFlowViewModel()
    )
    .environmentObject(Router())
}
