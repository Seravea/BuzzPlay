//
//  ScoreMasterView.swift
//  BuzzPlay
//

import SwiftUI

struct ScoreMasterView: View {
    var masterFlowVM: MasterFlowViewModel
    @EnvironmentObject private var router: Router

    private var sorted: [Player] {
        masterFlowVM.players.sorted { $0.score > $1.score }
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    podiumSection
                    if sorted.count > 3 { othersSection }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.sm)
            }

            VStack {
                Spacer()
                ScoreFooterButtons(
                    onQuit: {
                        // #quit-teardown — prévient les Players, coupe heartbeat + session, reset l'état.
                        masterFlowVM.leaveSessionAsMaster()
                        router.popToRoot()
                    },
                    onNewGame: {
                        masterFlowVM.resetForNewGame()
                        router.popToRoot()
                        router.push(.masterLobbyView)
                    }
                )
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: BuzzSpacing.xs) {
            Text("PARTIE TERMINÉE")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color.mustardYellow)

            Text("Classement final")
                .font(.nohemi(.title, weight: .black)).titleTracking()
                .foregroundStyle(.white)
        }
        .padding(.top, BuzzSpacing.md)
        .padding(.bottom, 28)
    }

    // MARK: - Podium

    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: BuzzSpacing.sm) {
            if sorted.count >= 2 { PodiumSlot(rank: 2, player: sorted[1]) }
            if sorted.count >= 1 { PodiumSlot(rank: 1, player: sorted[0]) }
            if sorted.count >= 3 { PodiumSlot(rank: 3, player: sorted[2]) }
        }
        .padding(.bottom, 28)
    }

    // MARK: - Others

    private var othersSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text("ET LES AUTRES…")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.textMuted)
                Spacer()
                Text("\(sorted.count - 3)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
            }

            VStack(spacing: 6) {
                ForEach(Array(sorted.dropFirst(3).enumerated()), id: \.element.id) { index, player in
                    othersRow(rank: index + 4, player: player)
                }
            }
        }
        .padding(.bottom, BuzzSpacing.xxl)
    }

    private func othersRow(rank: Int, player: Player) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            Text("\(rank)")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 18, alignment: .center)

            BuzzCountBadge(String(player.name.prefix(1)).uppercased(),
                           diameter: 32, fontSize: 12, weight: .bold,
                           fill: AnyShapeStyle(player.teamColor.gradient),
                           textColor: .white)

            Text(player.name)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Text("\(player.score)")
                .font(.nohemi(.subheadline, weight: .black))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.sm)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ScoreMasterView(masterFlowVM: {
            let vm = MasterFlowViewModel()
            vm.players = [
                Player(name: "Léa", teamColor: .redGame),
                Player(name: "Max", teamColor: .greenGame),
                Player(name: "Tom", teamColor: .blueGame),
                Player(name: "Iris", teamColor: .yellowGame),
                Player(name: "Sam", teamColor: .purpleGame),
            ]
            vm.players[0].score = 240
            vm.players[1].score = 180
            vm.players[2].score = 120
            vm.players[3].score = 90
            vm.players[4].score = 60
            return vm
        }())
        .environmentObject(Router())
    }
}
