//
//  MasterGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct MasterChooseGameView: View {
    @Bindable var masterChooseGameVM: MasterChooseGameViewModel
    @EnvironmentObject private var router: Router
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let accentColor = Color.white

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    sessionHeader
                    gamesSection
                }
                .padding(.horizontal, sizeClass == .regular ? 0 : 20)
                .padding(.top, 20)
                .frame(maxWidth: sizeClass == .regular ? 700 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: masterChooseGameVM.connectedPlayersCount,
                    total: masterChooseGameVM.totalPlayersCount
                )
            }
        }
        .appDefaultTextStyle(Typography.body)
    }

    // MARK: - Session Header

    private var sessionHeader: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(accentColor)
                .frame(width: 12, height: 12)

            Text("Maître du jeu")
                .font(.nohemi(.title2, weight: .extraBold))
                .foregroundStyle(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(masterChooseGameVM.connectedPlayersCount)/\(masterChooseGameVM.totalPlayersCount)")
                    .font(.nohemi(.title2, weight: .extraBold))
                    .foregroundStyle(accentColor)
                Text("joueurs")
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

    // MARK: - Games Section

    @ViewBuilder
    private var gamesSection: some View {
        if sizeClass == .regular {
            HStack(spacing: 16) {
                ForEach([GameType.quiz, GameType.blindTest], id: \.self) { game in
                    gameCard(game)
                }
                scoreManageRow
            }
        } else {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    gameCard(.quiz)
                    gameCard(.blindTest)
                }
                scoreManageRow
            }
        }
    }

    // MARK: - Game Card

    @ViewBuilder
    private func gameCard(_ game: GameType) -> some View {
        let isOpen = masterChooseGameVM.gameIsAvailable(game)

        VStack(spacing: 0) {
            Button {
                if isOpen { router.push(game.destinationMaster) }
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 140)
            }
            .buttonStyle(.plain)
            .disabled(!isOpen)

            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 1)

            HStack(spacing: 8) {
                Button {
                    masterChooseGameVM.addGame(game)
                } label: {
                    Text("Ouvrir")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(isOpen ? .white.opacity(0.3) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isOpen ? .white.opacity(0.04) : .green.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isOpen)

                Button {
                    masterChooseGameVM.removeGame(game)
                } label: {
                    Text("Fermer")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(!isOpen ? .white.opacity(0.3) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            !isOpen ? .white.opacity(0.04) : Color(red: 1, green: 0.2, blue: 0.3).opacity(0.25),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isOpen)
            }
            .padding(12)
        }
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOpen)
    }

    // MARK: - Score Row (Master controls)

    private var scoreManageRow: some View {
        let isOpen = masterChooseGameVM.gameIsAvailable(.score)
        return HStack(spacing: 14) {
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

            HStack(spacing: 6) {
                Button {
                    masterChooseGameVM.addGame(.score)
                } label: {
                    Text("Ouvrir")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(isOpen ? .white.opacity(0.3) : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isOpen ? .white.opacity(0.04) : .green.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isOpen)

                Button {
                    masterChooseGameVM.removeGame(.score)
                } label: {
                    Text("Fermer")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(!isOpen ? .white.opacity(0.3) : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            !isOpen ? .white.opacity(0.04) : Color(red: 1, green: 0.2, blue: 0.3).opacity(0.25),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isOpen)
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
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOpen)
    }

    // MARK: - Status Badge

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

#Preview {
    MasterChooseGameView(masterChooseGameVM: MasterChooseGameViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}
