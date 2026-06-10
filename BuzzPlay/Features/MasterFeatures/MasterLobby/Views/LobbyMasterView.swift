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
                VStack(spacing: BuzzSpacing.xl) {
                    configSection
                    summaryPill
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                        .padding(.vertical, 4)
                    playersSection
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.lg)
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
        .masterDarkNavBar()  // #8
    }

    // MARK: - Config section

    private var configSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
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
                        withAnimation(.buzzDefault) {
                            masterGameVM.gameDuration = duration
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: duration.iconName)
                                .textStyle(Typography.cardTitle)
                                .foregroundStyle(isSelected ? Color.mustardYellow : Color.textSecondary)
                            Text(duration.label)
                                .font(.nohemi(.subheadline, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.70))
                            Text(duration.subtitle)
                                .font(.nohemi(.caption2, weight: .medium))
                                .foregroundStyle(isSelected ? .white.opacity(0.75) : Color.textDim)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.05),
                            in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: BuzzRadius.md)
                                .strokeBorder(
                                    isSelected ? Color.mustardYellow.opacity(0.6) : Color.white.opacity(0.10),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.buzzDefault, value: isSelected)
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
                        withAnimation(.buzzDefault) {
                            masterGameVM.gameMode = mode
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mode.iconName)
                                .textStyle(Typography.label)
                                .foregroundStyle(isSelected ? .white : Color.textSecondary)
                            Text(mode.label)
                                .font(.nohemi(.subheadline, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.70))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(modeBackground(mode, isSelected: isSelected))
                        .overlay(
                            RoundedRectangle(cornerRadius: BuzzRadius.md)
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.white.opacity(0.10),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.buzzDefault, value: isSelected)
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
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))
                )
            case .blindTest:
                AnyView(
                    LinearGradient(
                        colors: [Color.blueLeading, Color.blueTrailing],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))
                )
            case .mix:
                AnyView(
                    LinearGradient(
                        colors: [Color.purpleLeading, Color.blueTrailing],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))
                )
            }
        } else {
            AnyView(
                Color.white.opacity(0.05)
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))
            )
        }
    }

    private var mixInfoPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain")
                .textStyle(Typography.caption2EM)
                .foregroundStyle(Color.purpleLeading)
            Text("\(masterGameVM.quizRoundsTotal) Quiz")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
            Text("·")
                .foregroundStyle(.white.opacity(0.3))
            Image(systemName: "music.note")
                .textStyle(Typography.caption2EM)
                .foregroundStyle(Color.blueLeading)
            Text("\(masterGameVM.blindTestRoundsTotal) Blind Test")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, BuzzSpacing.sm)
        .background(.white.opacity(0.06), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.10), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Summary Pill

    private var summaryPill: some View {
        Text("\(masterGameVM.totalRounds) manches · \(masterGameVM.gameMode.label)")
            .font(.nohemi(.caption, weight: .bold))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.sm)
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
                        .foregroundStyle(Color.textMuted)
                }
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.bottom, BuzzSpacing.md)

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
        VStack(spacing: BuzzSpacing.md) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 64, height: 64)
                Image(systemName: "person.3")
                    .textStyle(Typography.screenTitleSoft)
                    .foregroundStyle(.white.opacity(0.30))
            }
            VStack(spacing: BuzzSpacing.xs) {
                Text("En attente de joueurs…")
                    .font(.nohemi(.subheadline, weight: .semiBold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Demande aux joueurs de rejoindre la partie")
                    .font(.nohemi(.caption))
                    .foregroundStyle(Color.textDim)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, BuzzSpacing.xxl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            masterGameVM.startParty()
            router.push(.masterChooseGameView)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .textStyle(Typography.labelBold)
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
                in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
            )
            .shadow(
                color: masterGameVM.players.isEmpty ? .clear : Color.greenButtonLeading.opacity(0.32),
                radius: 12, y: 4
            )
        }
        .buttonStyle(.plain)
        .disabled(masterGameVM.players.isEmpty)
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.bottom, BuzzSpacing.xxxl)
        .padding(.top, BuzzSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.sheetBg.opacity(0), Color.sheetBg],
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
            .foregroundStyle(Color.textMuted)
    }
}

// MARK: - Team Row

private struct LobbyTeamRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
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
                .textStyle(Typography.cardTitle)
                .foregroundStyle(Color.greenGlow)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, BuzzSpacing.md)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.08), lineWidth: 1))
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
