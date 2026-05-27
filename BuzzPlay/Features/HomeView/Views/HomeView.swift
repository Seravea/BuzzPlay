//
//  HomeView.swift
//  BuzzPlay
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @State var playerFlowVM = PlayerFlowViewModel()
    @State var masterFlowVM = MasterFlowViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                // Hero section
                VStack(alignment: .leading, spacing: 0) {
                    Text("BUZZ · QUIZ · BLIND TEST")
                        .font(.nohemi(.caption2, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 12)

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
                VStack(spacing: 12) {
                    Button { router.push(Route.createTeamView) } label: {
                        HomeRoleCard(
                            title: "Rejoindre",
                            subtitle: "Avec un code à 4 chiffres",
                            iconName: "bolt.fill",
                            gradient: LinearGradient(
                                colors: [Color.purpleLeading, Color.purpleTrailing],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            shadowColor: Color.purpleLeading.opacity(0.30)
                        )
                    }
                    .buttonStyle(.plain)

                    Button { router.push(Route.masterLobbyView) } label: {
                        HomeRoleCard(
                            title: "Animer",
                            subtitle: "Hôte de la partie",
                            iconName: "gamecontroller.fill",
                            gradient: LinearGradient(
                                colors: [Color.blueLeading, Color.blueTrailing],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            shadowColor: nil
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 32)
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
    }
}

// MARK: - Role card (HomeA style)

private struct HomeRoleCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: LinearGradient
    let shadowColor: Color?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.title2, weight: .extraBold))
                Text(subtitle)
                    .font(.nohemi(.subheadline))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(gradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: shadowColor ?? .clear, radius: 16, y: 6)
    }
}

#Preview {
    HomeView()
        .environmentObject(Router())
}
