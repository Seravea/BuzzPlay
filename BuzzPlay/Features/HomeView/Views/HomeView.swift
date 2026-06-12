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
    @State private var showResumePrompt = false
    @Environment(\.scenePhase) private var scenePhase

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
                            shadowColor: Color.purpleLeading.opacity(0.35)
                        )
                    }
                    .buttonStyle(.plain)

                    // Animer — bouton secondaire
                    Button {
                        // #resume — une partie récente a été interrompue (kill) → proposer de la reprendre.
                        if masterFlowVM.hasResumableParty { showResumePrompt = true }
                        else { showMasterConfirmation = true }
                    } label: {
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
                case .masterShop:
                    MasterShopView()
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
        }
        // #alert — attaché au NavigationStack (pas à son contenu) : évite le warning
        // "Presenting from detached view controller" quand le Master a navigué en profondeur.
        .alert(
            "Joueur déconnecté",
            isPresented: Binding(
                get: { masterFlowVM.disconnectedPlayerName != nil && !masterFlowVM.isGamePaused },
                set: { if !$0 { masterFlowVM.disconnectedPlayerName = nil } }
            )
        ) {
            Button("Attendre", role: .cancel) { masterFlowVM.disconnectedPlayerName = nil }
            // #E1 — échappatoire : si le joueur a quitté pour de bon, le retirer
            // débloque le garde-fou et permet de relancer une manche sans lui.
            if let name = masterFlowVM.disconnectedPlayerName {
                Button("Retirer le joueur", role: .destructive) {
                    masterFlowVM.forgetDisconnectedPlayer(name)
                }
            }
        } message: {
            if let name = masterFlowVM.disconnectedPlayerName {
                Text("Le joueur « \(name) » s'est déconnecté. Tu peux l'attendre (la prochaine manche ne se lancera pas sans lui) ou le retirer de la partie.")
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
        // #resume — proposition de reprendre une partie interrompue par un kill.
        .overlay {
            if showResumePrompt {
                ResumePartyOverlay(
                    onResume: {
                        masterFlowVM.restoreActiveParty()
                        masterFlowVM.setupMPC()
                        showResumePrompt = false
                        router.push(Route.masterChooseGameView)
                    },
                    onNewGame: {
                        masterFlowVM.clearActiveParty()
                        showResumePrompt = false
                        showMasterConfirmation = true
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showResumePrompt)
        // #resume — sauvegarde la partie Master juste avant un éventuel kill (passage background).
        .onChange(of: scenePhase) { _, phase in
            // #resume — on persiste sur .background ET .inactive : un force-quit rapide peut
            // tuer l'app avant qu'elle atteigne .background. .inactive capte l'état plus tôt
            // (le guard hasPartyStarted dans persistActiveParty filtre le bruit hors-partie).
            if phase == .background || phase == .inactive { masterFlowVM.persistActiveParty() }
        }
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
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
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

// MARK: - Overlay reprise de partie (#resume)

private struct ResumePartyOverlay: View {
    let onResume: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xxl) {
                VStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .textStyle(Typography.largeTitle)
                        .foregroundStyle(LinearGradient(
                            colors: [Color.greenButtonLeading, Color.greenTrailing],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))

                    Text("Reprendre la partie ?")
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Une partie en cours a été interrompue. Reprends-la (manches et scores conservés) — les joueurs se reconnectent tout seuls.")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                VStack(spacing: BuzzSpacing.md) {
                    Button(action: onResume) {
                        Text("Reprendre")
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

                    Button(action: onNewGame) {
                        Text("Nouvelle partie")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
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

// #R1 — métriques PARTAGÉES : les 2 cartes « Rejoindre » / « Animer » ont exactement
// la même géométrie (icône, paddings, espacements, flèche) ; seuls le fond, l'ombre et
// les opacités les distinguent (principal plein/dégradé vs secondaire discret).
// Valeurs à affiner à l'œil device si besoin.
private enum HomeCardMetrics {
    // Marge intérieure & alignements PARTAGÉS (même padding = marges alignées, #R1).
    // La taille d'icône/titre, elle, diffère par carte pour garder « Rejoindre » plus
    // grand (hiérarchie voulue par Romain) sans casser l'alignement des marges.
    static let iconTextSpacing: CGFloat = 14
    static let trailingPointSize: CGFloat = 18
    static let padding: CGFloat = 18
    static let corner: CGFloat = 22
}

private struct HomeRoleCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: LinearGradient
    let shadowColor: Color?

    var body: some View {
        HStack(spacing: HomeCardMetrics.iconTextSpacing) {
            Image(systemName: iconName)
                .font(.system(size: 28, weight: .semibold))   // taille SF Symbol — carte principale (plus grande)
                .frame(width: 58, height: 58)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.title, weight: .extraBold))
                Text(subtitle)
                    .font(.nohemi(.subheadline))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: HomeCardMetrics.trailingPointSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
        }
        .foregroundStyle(.white)
        .padding(HomeCardMetrics.padding)
        .background(gradient, in: RoundedRectangle(cornerRadius: HomeCardMetrics.corner))
        .shadow(color: shadowColor ?? .clear, radius: 20, y: 8)
    }
}

private struct HomeSecondaryCard: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        HStack(spacing: HomeCardMetrics.iconTextSpacing) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))   // taille SF Symbol — carte secondaire (plus petite)
                .foregroundStyle(.white.opacity(0.80))
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.title3, weight: .extraBold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.nohemi(.subheadline))
                    .foregroundStyle(.white.opacity(0.60))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: HomeCardMetrics.trailingPointSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(HomeCardMetrics.padding)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: HomeCardMetrics.corner))
        .overlay(RoundedRectangle(cornerRadius: HomeCardMetrics.corner).strokeBorder(.white.opacity(0.18), lineWidth: 1))
    }
}

#Preview {
    HomeView()
        .environmentObject(Router())
}
