//
//  MasterGameView.swift
//  BuzzPlay
//

import SwiftUI

struct MasterChooseGameView: View {
    @Bindable var masterChooseGameVM: MasterChooseGameViewModel
    @EnvironmentObject private var router: Router

    // #terminer — confirmation avant de clôturer la partie (anti mis-tap).
    @State private var showEndConfirm = false

    private var hasScores: Bool {
        masterChooseGameVM.players.map(\.score).max() ?? 0 > 0
    }

    private var quizGradient: LinearGradient {
        LinearGradient(
            colors: [Color.purpleLeading, Color.purpleTrailing],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var blindTestGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blueLeading, Color.blueTrailing],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: BuzzSpacing.xl) {
                    launchSection
                    shopSection
                    if hasScores { rankingSection }
                    endPartySection
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xxxl)
            }
        }
        .alert("Terminer la partie ?", isPresented: $showEndConfirm) {
            Button("Annuler", role: .cancel) { }
            Button("Terminer", role: .destructive) {
                masterChooseGameVM.endPartyEarly()
                router.push(.scoreMaster)
            }
        } message: {
            Text("La partie sera close et le classement final affiché à tous les joueurs.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BPWordmarkView(size: 28)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: masterChooseGameVM.connectedPlayersCount,
                    total: masterChooseGameVM.totalPlayersCount
                )
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
        // #8 — nav bar dark même au scroll (iOS < 26 la repassait en light). Modifier partagé.
        .masterDarkNavBar()
        // #18a — la veille est désormais désactivée pour TOUTE la session Master
        // dans MasterFlowViewModel.setupMPC() (couvre aussi les écrans de jeu).
    }

    // MARK: - Eyebrow

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.nohemi(.caption2, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(Color.textMuted)
    }

    // MARK: - Launch Section

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack {
                eyebrow("Lancer une manche")
                Spacer()
                if masterChooseGameVM.isUnlimited {
                    // Symbole interpolé DANS le Text → aligné sur la ligne de base Nohemi.
                    Text("\(Image(systemName: "infinity"))  Mode libre")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.mustardYellow)
                } else if masterChooseGameVM.currentRound >= 1 {
                    Text("Manche \(masterChooseGameVM.currentRound)/\(masterChooseGameVM.totalRounds)")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                }
            }
            HStack(spacing: BuzzSpacing.md) {
                GameLaunchCard(game: .quiz, gradient: quizGradient, vm: masterChooseGameVM) {
                    masterChooseGameVM.trackAndLaunch(.quiz)
                    router.push(GameType.quiz.destinationMaster)
                }
                GameLaunchCard(game: .blindTest, gradient: blindTestGradient, vm: masterChooseGameVM) {
                    masterChooseGameVM.trackAndLaunch(.blindTest)
                    router.push(GameType.blindTest.destinationMaster)
                }
            }
        }
    }

    // MARK: - Shop Section (#v1-packs / A4 — M1 : boutique dans le hub Master)

    private var shopSection: some View {
        Button { router.push(.masterShop) } label: {
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: "bag.fill")
                    .textStyle(Typography.sectionTitle)
                    .foregroundStyle(Color.mustardYellow)
                    .frame(width: 48, height: 48)
                    .background(Color.mustardYellow.opacity(0.15), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Boutique")
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Packs de quiz à débloquer")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .textStyle(Typography.footnoteEM)
                    .foregroundStyle(Color.textFaint)
            }
            .padding(BuzzSpacing.md)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.xl)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - End Party Section (#terminer)

    private var endPartySection: some View {
        Button { showEndConfirm = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .textStyle(Typography.footnoteEM)
                Text("Terminer la partie")
                    .font(.nohemi(.subheadline, weight: .bold))
            }
            .foregroundStyle(Color.redLeading)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.redLeading.opacity(0.10), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(Color.redLeading.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, BuzzSpacing.sm)
    }

    // MARK: - Ranking Section

    private var rankingSection: some View {
        let sorted = masterChooseGameVM.players.sorted { $0.score > $1.score }
        let maxScore = max(sorted.first?.score ?? 1, 1)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                eyebrow("Classement")
                Spacer()
                Text("mi-partie")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(Color.textMuted)
            }

            VStack(spacing: 6) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, player in
                    MasterRankingRow(rank: index + 1, player: player, maxScore: maxScore)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.xl)
                .strokeBorder(.white.opacity(0.07), lineWidth: 1)
        )
    }
}


#Preview {
    NavigationStack {
        MasterChooseGameView(
            masterChooseGameVM: MasterChooseGameViewModel(gameVM: MasterFlowViewModel())
        )
        .environmentObject(Router())
    }
}
