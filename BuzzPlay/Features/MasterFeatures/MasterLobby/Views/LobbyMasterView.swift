//
//  LobbyMasterView.swift
//  BuzzPlay
//

import SwiftUI

struct LobbyMasterView: View {
    @EnvironmentObject var router: Router
    @Bindable var masterGameVM: MasterLobbyViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    configSection
                    summaryPill
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                        .padding(.vertical, 4)
                    playersSection
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            startButton
        }
        .foregroundStyle(.white)
        .appDefaultTextStyle(Typography.body)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BPWordmarkView(size: 28)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: masterGameVM.connectedPlayersCount,
                    total: masterGameVM.totalPlayersCount
                )
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Config section

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            durationSection
            modeSection
        }
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow("Durée")
            HStack(spacing: 10) {
                ForEach(GameDuration.allCases, id: \.self) { duration in
                    let isSelected = masterGameVM.gameDuration == duration
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            masterGameVM.gameDuration = duration
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: duration.iconName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(isSelected ? Color.mustardYellow : .white.opacity(0.55))
                            Text(duration.label)
                                .font(.nohemi(.subheadline, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.70))
                            Text(duration.subtitle)
                                .font(.nohemi(.caption2, weight: .medium))
                                .foregroundStyle(isSelected ? .white.opacity(0.75) : .white.opacity(0.35))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.05),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    isSelected ? Color.mustardYellow.opacity(0.6) : Color.white.opacity(0.10),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }
            }
        }
    }

    // MARK: - Mode

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow("Mode de jeu")
            HStack(spacing: 10) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    let isSelected = masterGameVM.gameMode == mode
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            masterGameVM.gameMode = mode
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                            Text(mode.label)
                                .font(.nohemi(.subheadline, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.70))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(modeBackground(mode, isSelected: isSelected))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.white.opacity(0.10),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }
            }

            if masterGameVM.gameMode == .mix {
                mixInfoPill
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: masterGameVM.gameMode)
    }

    @ViewBuilder
    private func modeBackground(_ mode: GameMode, isSelected: Bool) -> some View {
        if isSelected {
            switch mode {
            case .quiz:
                AnyView(
                    LinearGradient(
                        colors: [Color.purpleLeading, Color.purpleTrailing],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )
            case .blindTest:
                AnyView(
                    LinearGradient(
                        colors: [Color.blueLeading, Color.blueTrailing],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )
            case .mix:
                AnyView(
                    LinearGradient(
                        colors: [Color.purpleLeading, Color.blueTrailing],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )
            }
        } else {
            AnyView(
                Color.white.opacity(0.05)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            )
        }
    }

    private var mixInfoPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.purpleLeading)
            Text("\(masterGameVM.quizRoundsTotal) Quiz")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
            Text("·")
                .foregroundStyle(.white.opacity(0.3))
            Image(systemName: "music.note")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.blueLeading)
            Text("\(masterGameVM.blindTestRoundsTotal) Blind Test")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white.opacity(0.06), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.10), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Summary Pill

    private var summaryPill: some View {
        Text("\(masterGameVM.totalRounds) manches · \(masterGameVM.gameMode.label)")
            .font(.nohemi(.caption, weight: .bold))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.10), lineWidth: 1))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Players Section

    private var playersSection: some View {
        VStack(spacing: 0) {
            HStack {
                eyebrow("Joueurs connectés")
                if !masterGameVM.players.isEmpty {
                    Text("· \(masterGameVM.players.count)")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.40))
                }
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.bottom, 12)

            if masterGameVM.players.isEmpty {
                emptyPlayersState
            } else {
                VStack(spacing: 10) {
                    ForEach(masterGameVM.players) { player in
                        LobbyTeamRow(player: player)
                    }
                }
            }
        }
    }

    private var emptyPlayersState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 64, height: 64)
                Image(systemName: "person.3")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white.opacity(0.30))
            }
            VStack(spacing: 4) {
                Text("En attente de joueurs…")
                    .font(.nohemi(.subheadline, weight: .semiBold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Demande aux joueurs de rejoindre la partie")
                    .font(.nohemi(.caption))
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            router.push(.masterChooseGameView)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("Commencer la partie")
                    .font(.nohemi(.body, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                masterGameVM.players.isEmpty
                    ? AnyShapeStyle(Color.white.opacity(0.12))
                    : AnyShapeStyle(LinearGradient(
                        colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                        startPoint: .leading, endPoint: .trailing
                    )),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(
                color: masterGameVM.players.isEmpty ? .clear : Color.greenButtonLeading.opacity(0.32),
                radius: 12, y: 4
            )
        }
        .buttonStyle(.plain)
        .disabled(masterGameVM.players.isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "1A0535").opacity(0), Color(hex: "1A0535")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Helpers

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.nohemi(.caption2, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.40))
    }
}

// MARK: - Team Row

private struct LobbyTeamRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(player.teamColor.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(.white)
                )

            Text(player.name)
                .font(.nohemi(.body, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.greenGlow)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

#Preview {
    NavigationStack {
        LobbyMasterView(masterGameVM: {
            let vm = MasterLobbyViewModel(gameVM: MasterFlowViewModel())
            return vm
        }())
        .environmentObject(Router())
    }
}

#Preview("Avec joueurs") {
    NavigationStack {
        LobbyMasterView(masterGameVM: {
            let gameVM = MasterFlowViewModel()
            gameVM.players = [
                Player(name: "Léa", teamColor: .redGame),
                Player(name: "Romain", teamColor: .greenGame),
                Player(name: "Tom", teamColor: .blueGame),
            ]
            return MasterLobbyViewModel(gameVM: gameVM)
        }())
        .environmentObject(Router())
    }
}
