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

    var body: some View {
        Group {
            if sizeClass == .regular {
                ipadLayout
            } else {
                iphoneLayout
            }
        }
        .background(BackgroundAppView())
        .appDefaultTextStyle(Typography.body)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: masterChooseGameVM.connectedTeamsCount,
                    total: masterChooseGameVM.totalTeamsCount
                )
            }
        }
    }

    private var ipadLayout: some View {
        GeometryReader { geo in
            HStack(spacing: 24) {
                ForEach(masterChooseGameVM.allGames, id: \.self) { game in
                    gameCard(game)
                        .frame(width: (geo.size.width - 96) / 3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
        }
    }

    private var iphoneLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(masterChooseGameVM.allGames, id: \.self) { game in
                    gameCard(game)
                        .frame(width: 200)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
            .frame(maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func gameCard(_ game: GameType) -> some View {
        VStack(spacing: 12) {
            ButtonChooseGameView(
                isOpen: masterChooseGameVM.gameIsAvailable(game),
                action: { router.push(game.destinationMaster) },
                title: game.gameTitle,
                iconName: game.iconName
            )
            HStack(spacing: 8) {
                PrimaryButtonView(title: "Ouvrir", action: {
                    masterChooseGameVM.addGame(game)
                }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                .disabled(masterChooseGameVM.gameIsAvailable(game))
                .opacity(masterChooseGameVM.gameIsAvailable(game) ? 0.5 : 1)

                PrimaryButtonView(title: "Fermer", action: {
                    masterChooseGameVM.removeGame(game)
                }, style: .outlined(buttonStyle: .destructive), fontSize: Typography.body)
                .disabled(!masterChooseGameVM.gameIsAvailable(game))
                .opacity(!masterChooseGameVM.gameIsAvailable(game) ? 0.5 : 1)
            }
        }
    }
}

#Preview {
    MasterChooseGameView(masterChooseGameVM: MasterChooseGameViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}


