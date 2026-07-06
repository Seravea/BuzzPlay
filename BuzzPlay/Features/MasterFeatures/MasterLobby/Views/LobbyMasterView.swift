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
                    if masterGameVM.configComplete {
                        summaryPill
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                        .padding(.vertical, 4)
                    playersSection
                    Spacer(minLength: 80)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: masterGameVM.configComplete)
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.lg)
            }

            LobbyStartButton(masterGameVM: masterGameVM) {
                masterGameVM.startParty()
                router.push(.masterChooseGameView)
            }
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
            // #config-explicite — Étape 2 cachée tant que la durée n'est pas choisie.
            // En illimité, le mode est forcé (« libre ») → on montre un encart, pas un choix.
            if masterGameVM.durationChosen {
                if masterGameVM.isUnlimited {
                    libreModeInfo
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                } else {
                    modeSection
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: masterGameVM.durationChosen)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: masterGameVM.isUnlimited)
    }

    // MARK: - Duration (Étape 1)

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow("Étape 1 · Durée")
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(GameDuration.allCases, id: \.self) { duration in
                    // #config-explicite — aucun défaut surligné tant que rien n'est choisi.
                    let isSelected = masterGameVM.durationChosen && masterGameVM.gameDuration == duration
                    Button {
                        withAnimation(.buzzDefault) {
                            masterGameVM.selectDuration(duration)
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

    // MARK: - Mode libre (illimité)

    private var libreModeInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow("Étape 2 · Mode")
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: "infinity")
                    .textStyle(Typography.cardTitle)
                    .foregroundStyle(Color.mustardYellow)
                    .frame(width: 44, height: 44)
                    .background(Color.mustardYellow.opacity(0.15), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mode libre")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Quiz + Blind Test à volonté, sans limite")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
            }
            .padding(BuzzSpacing.md)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
    }

    // MARK: - Mode (Étape 2)

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            eyebrow("Étape 2 · Mode")
            HStack(spacing: 10) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    let isSelected = masterGameVM.modeChosen && masterGameVM.gameMode == mode
                    Button {
                        withAnimation(.buzzDefault) {
                            masterGameVM.selectMode(mode)
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

    private var summaryText: String {
        masterGameVM.isUnlimited
            ? "Illimité · Mode libre"
            : "\(masterGameVM.totalRounds) manches · \(masterGameVM.gameMode.label)"
    }

    private var summaryPill: some View {
        Text(summaryText)
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

    // MARK: - Helpers

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.nohemi(.caption2, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(Color.textMuted)
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
