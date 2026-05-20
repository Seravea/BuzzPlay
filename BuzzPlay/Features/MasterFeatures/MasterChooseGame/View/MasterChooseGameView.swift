//
//  MasterGameView.swift
//  BuzzPlay
//

import SwiftUI

struct MasterChooseGameView: View {
    @Bindable var masterChooseGameVM: MasterChooseGameViewModel
    @EnvironmentObject private var router: Router

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
                VStack(spacing: 20) {
                    launchSection
                    if hasScores { rankingSection }
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
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
    }

    // MARK: - Eyebrow

    private func eyebrow(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.nohemi(.caption2, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.40))
    }

    // MARK: - Launch Section

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                eyebrow("Lancer une manche")
                Spacer()
                if masterChooseGameVM.currentRound >= 1 {
                    Text("Manche \(masterChooseGameVM.currentRound)/\(masterChooseGameVM.totalRounds)")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.40))
                }
            }
            HStack(spacing: 12) {
                gameCard(.quiz, gradient: quizGradient)
                gameCard(.blindTest, gradient: blindTestGradient)
            }
        }
    }

    @ViewBuilder
    private func gameCard(_ game: GameType, gradient: LinearGradient) -> some View {
        let isAvailable: Bool = game == .quiz
            ? masterChooseGameVM.isQuizCardAvailable
            : masterChooseGameVM.isBlindTestCardAvailable

        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: game.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(gradient.opacity(isAvailable ? 0.25 : 0.10), in: RoundedRectangle(cornerRadius: 16))

                Text(game.gameTitle)
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(isAvailable ? .white : .white.opacity(0.35))
                    .lineLimit(1)
            }
            .padding(.top, 18)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 1)

            Button {
                masterChooseGameVM.trackAndLaunch(game)
                router.push(game.destinationMaster)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isAvailable ? game.iconName : "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text(isAvailable ? "Lancer" : "Terminé")
                        .font(.nohemi(.subheadline, weight: .bold))
                }
                .foregroundStyle(isAvailable ? .white : .white.opacity(0.40))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    isAvailable ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.white.opacity(0.06)),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isAvailable)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(isAvailable ? 0.10 : 0.04), lineWidth: 1)
        )
        .opacity(isAvailable ? 1 : 0.55)
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
                    .foregroundStyle(.white.opacity(0.4))
            }

            VStack(spacing: 6) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, player in
                    rankingRow(rank: index + 1, player: player, maxScore: maxScore)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func rankingRow(rank: Int, player: Player, maxScore: Int) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(rank == 1 ? Color.mustardYellow : .white.opacity(0.10))
                    .frame(width: 24, height: 24)
                Text("\(rank)")
                    .font(.nohemi(.caption2, weight: .black))
                    .foregroundStyle(rank == 1 ? Color(hex: "1A0535") : .white.opacity(0.6))
            }

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.callout, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text("\(player.score)")
                        .font(.nohemi(.subheadline, weight: .black))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 999)
                        .fill(.white.opacity(0.10))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 999)
                                .fill(player.teamColor.gradient)
                                .frame(width: geo.size.width * CGFloat(player.score) / CGFloat(maxScore))
                        }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            rank == 1 ? Color.mustardYellow.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "music.note")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.mustardYellow)
                    .frame(width: 42, height: 42)
                    .background(Color.mustardYellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Notes ♪")
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Envoyer aux joueurs")
                        .font(.nohemi(.caption2, weight: .regular))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Spacer()
            }

            if masterChooseGameVM.players.isEmpty {
                Text("Aucun joueur connecté")
                    .font(.nohemi(.caption, weight: .regular))
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(masterChooseGameVM.players) { player in
                            Menu {
                                ForEach(masterChooseGameVM.coinsVM.moneyCanSend, id: \.self) { amount in
                                    Button {
                                        masterChooseGameVM.coinsVM.sendCoinsToPlayer(player, amount: amount)
                                    } label: {
                                        Label("\(amount) notes", systemImage: "music.note")
                                    }
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(player.teamColor.gradient)
                                        .frame(width: 42, height: 42)
                                        .overlay(
                                            Text(String(player.name.prefix(1)).uppercased())
                                                .font(.nohemi(.callout, weight: .bold))
                                                .foregroundStyle(.white)
                                        )
                                    Text(player.name)
                                        .font(.nohemi(.caption2, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .lineLimit(1)
                                    Image(systemName: "music.note")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.mustardYellow.opacity(0.7))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1.5)
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
