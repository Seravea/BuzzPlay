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
                VStack(spacing: 10) {
                    // Rejoindre — bouton principal
                    Button { router.push(Route.createTeamView) } label: {
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

                    // Animer — bouton secondaire discret
                    Button { showMasterConfirmation = true } label: {
                        HomeSecondaryCard(title: "Animer", subtitle: "Hôte de la partie", iconName: "gamecontroller.fill")
                    }
                    .buttonStyle(.plain)
                    .alert("Tu vas animer la partie", isPresented: $showMasterConfirmation) {
                        Button("Annuler", role: .cancel) { }
                        Button("Continuer") { router.push(Route.masterLobbyView) }
                    } message: {
                        Text("Assure-toi d'être le bon appareil avant de lancer.")
                    }
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
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))

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
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white.opacity(0.75))
                Text(subtitle)
                    .font(.nohemi(.caption, weight: .regular))
                    .foregroundStyle(.white.opacity(0.40))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.30))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.10), lineWidth: 1))
    }
}

#Preview {
    HomeView()
        .environmentObject(Router())
}
