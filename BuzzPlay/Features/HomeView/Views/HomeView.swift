//
//  HomeView.swift
//  BuzzPlay
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @State var playerFlowVM = PlayerFlowViewModel()
    @State var masterFlowVM = MasterFlowViewModel()
    @State private var showMasterConfirmation = false

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                // Hero section
                VStack(alignment: .leading, spacing: 0) {
                    Text("BUZZ · QUIZ · BLIND TEST")
                        .font(.nohemi(.caption2, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.bottom, BuzzSpacing.md)

                    BPWordmarkView(size: 64)

                    Text("Le party-game qui transforme tes potes en équipe.")
                        .font(.nohemi(.body))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(3)
                        .padding(.top, 14)
                }
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // CTA cards
                VStack(spacing: 10) {
                    // Rejoindre — bouton principal
                    Button {
                        // #A1 — démarre MPC dès le tap pour déclencher la permission réseau local
                        // avant que le joueur arrive sur CreateTeamView
                        playerFlowVM.prewarmMPC()
                        router.push(Route.createTeamView)
                    } label: {
                        HomeRoleCard(
                            title: "Rejoindre",
                            subtitle: "Rejoins la partie d'un hôte",
                            iconName: "bolt.fill",
                            gradient: LinearGradient(
                                colors: [Color.purpleLeading, Color.purpleTrailing],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            isPrimary: true,
                            shadowColor: Color.purpleLeading.opacity(0.35)
                        )
                    }
                    .buttonStyle(.plain)

                    // Animer — bouton secondaire
                    Button { showMasterConfirmation = true } label: {
                        HomeSecondaryCard(title: "Animer", subtitle: "Hôte de la partie", iconName: "gamecontroller.fill")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, BuzzSpacing.xxxl)
            }
            .background(BackgroundAppView())
            .foregroundStyle(.white)
            .appDefaultTextStyle(Typography.body)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .homeView:
                    HomeView()
                case .masterChooseGameView:
                    MasterChooseGameView(masterChooseGameVM: masterFlowVM.makeChooseGameVM())
                case .masterLobbyView:
                    LobbyMasterView(masterGameVM: masterFlowVM.makeLobbyViewModel())
                case .playerChooseGameView:
                    if let vm = playerFlowVM.playerGameVM {
                        PlayerChooseGameView(playerGameVM: vm, playerFlowVM: playerFlowVM)
                    } else {
                        Text("Pas de joueur — erreur inattendue")
                    }
                case .blindTestMaster:
                    BlindTestMasterView(blindTestViewModel: masterFlowVM.makeBlindTestMasterVM())
                case .blindTestPlayer:
                    if let playerGameVM = playerFlowVM.playerGameVM {
                        BuzzerPlayerView(playerGameVM: playerGameVM, gameType: .blindTest)
                    }
                case .createTeamView:
                    CreateTeamView(createTeamVM: playerFlowVM.makeCreateTeamViewModel())
                case .quizMaster:
                    QuizMasterListView(quizMasterVM: masterFlowVM.makeQuizMasterVM())
                case .quizPlayer:
                    if let playerGameVM = playerFlowVM.playerGameVM {
                        BuzzerPlayerView(playerGameVM: playerGameVM, gameType: .quiz)
                    }
                case .quizThemeSelection:
                    QuizThemeSelectionView(viewModel: masterFlowVM.makeQuizThemeSelectionVM())
                case .scoreMaster:
                    ScoreMasterView(masterFlowVM: masterFlowVM)
                case .scorePlayer:
                    if let playerGameVM = playerFlowVM.playerGameVM {
                        ScorePlayerView(playerGameVM: playerGameVM)
                    }
                case .playerGameView:
                    if let playerGameVM = playerFlowVM.playerGameVM {
                        PlayerGameView(playerGameVM: playerGameVM, playerFlowVM: playerFlowVM)
                    }
                }
            }
            .alert(
                "Joueur déconnecté",
                isPresented: Binding(
                    get: { masterFlowVM.disconnectedPlayerName != nil && !masterFlowVM.isGamePaused },
                    set: { if !$0 { masterFlowVM.disconnectedPlayerName = nil } }
                )
            ) {
                Button("OK") { masterFlowVM.disconnectedPlayerName = nil }
            } message: {
                if let name = masterFlowVM.disconnectedPlayerName {
                    Text("Le joueur « \(name) » s'est déconnecté.")
                }
            }
        }
        .overlay {
            if masterFlowVM.isGamePaused {
                GamePausedOverlay(playerName: masterFlowVM.disconnectedPlayerName)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: masterFlowVM.isGamePaused)
        .overlay {
            if showMasterConfirmation {
                MasterConfirmOverlay(
                    onConfirm: {
                        // Démarre MPC immédiatement → alerte réseau local dès le tap (#A1)
                        masterFlowVM.setupMPC()
                        showMasterConfirmation = false
                        router.push(Route.masterLobbyView)
                    },
                    onCancel: { showMasterConfirmation = false }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showMasterConfirmation)
    }
}

// MARK: - Overlay confirmation Master

private struct MasterConfirmOverlay: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xxl) {
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .textStyle(Typography.largeTitle)
                        .foregroundStyle(LinearGradient(
                            colors: [Color.blueLeading, Color.blueTrailing],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))

                    Text("Prêt à mener la danse ?")
                        .font(.nohemi(.title2, weight: .extraBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Tu vas animer la partie en tant qu'hôte. Les joueurs pourront te rejoindre depuis leur iPhone.")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: BuzzSpacing.md) {
                    Button(action: onCancel) {
                        Text("Annuler")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                    }

                    Button(action: onConfirm) {
                        Text("C'est parti !")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.greenButtonLeading, Color.greenTrailing],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                            )
                    }
                }
            }
            .padding(28)
            .background(
                Color.sheetBg,
                in: RoundedRectangle(cornerRadius: BuzzRadius.sheet)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
            .padding(.horizontal, BuzzSpacing.xxl)
        }
    }
}

// MARK: - Role cards

private struct HomeRoleCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: LinearGradient
    var isPrimary: Bool = false
    let shadowColor: Color?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: isPrimary ? 28 : 24, weight: .semibold))
                .frame(width: isPrimary ? 60 : 52, height: isPrimary ? 60 : 52)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(isPrimary ? .title : .title2, weight: .extraBold))
                Text(subtitle)
                    .font(.nohemi(isPrimary ? .subheadline : .callout))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: isPrimary ? 22 : 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
        }
        .foregroundStyle(.white)
        .padding(isPrimary ? 22 : 18)
        .background(gradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: shadowColor ?? .clear, radius: isPrimary ? 20 : 10, y: isPrimary ? 8 : 4)
    }
}

private struct HomeSecondaryCard: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            Image(systemName: iconName)
                .textStyle(Typography.cardTitle)
                .foregroundStyle(.white.opacity(0.80))
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.nohemi(.caption, weight: .regular))
                    .foregroundStyle(.white.opacity(0.60))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .textStyle(Typography.footnoteEM)
                .foregroundStyle(.white.opacity(0.50))
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, BuzzSpacing.md)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.18), lineWidth: 1))
    }
}

#Preview {
    HomeView()
        .environmentObject(Router())
}
