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
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

            VStack {
                Spacer()
                footerButtons
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {
            Text("PARTIE TERMINÉE")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color.mustardYellow)

            Text("Classement final")
                .font(.nohemi(.title, weight: .black))
                .foregroundStyle(.white)
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
    }

    // MARK: - Podium

    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if sorted.count >= 2 { podiumSlot(rank: 2, player: sorted[1]) }
            if sorted.count >= 1 { podiumSlot(rank: 1, player: sorted[0]) }
            if sorted.count >= 3 { podiumSlot(rank: 3, player: sorted[2]) }
        }
        .padding(.bottom, 28)
    }

    private func podiumSlot(rank: Int, player: Player) -> some View {
        let avatarSize: CGFloat = rank == 1 ? 72 : rank == 2 ? 56 : 48
        let blockHeight: CGFloat = rank == 1 ? 120 : rank == 2 ? 80 : 56
        let blockGradient: AnyShapeStyle = rank == 1
            ? AnyShapeStyle(LinearGradient(colors: [Color.mustardYellow, Color(hex: "FF6900")], startPoint: .top, endPoint: .bottom))
            : AnyShapeStyle(.white.opacity(rank == 2 ? 0.12 : 0.08))
        let blockRadius: CGFloat = rank == 1 ? 14 : 10

        return VStack(spacing: 0) {
            if rank == 1 {
                Text("👑")
                    .font(.system(size: 22))
                    .padding(.bottom, 4)
            }

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: avatarSize, height: avatarSize)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.custom("Nohemi-Black", size: avatarSize * 0.42))
                        .foregroundStyle(.white)
                )
                .overlay(
                    Circle()
                        .strokeBorder(rank == 1 ? Color.mustardYellow : .white.opacity(0.18), lineWidth: 2)
                )

            Text(player.name)
                .font(.nohemi(rank == 1 ? .subheadline : .caption, weight: .bold))
                .foregroundStyle(rank == 1 ? Color.mustardYellow : .white)
                .lineLimit(1)
                .padding(.top, 8)

            Text("\(player.score) pts")
                .font(.nohemi(.caption2, weight: .medium))
                .foregroundStyle(.white.opacity(rank == 1 ? 0.7 : 0.5))
                .padding(.top, 1)

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: blockRadius)
                    .fill(blockGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: blockRadius)
                            .strokeBorder(.white.opacity(rank == 1 ? 0 : 0.08), lineWidth: 1)
                    )

                Text("\(rank)")
                    .font(.custom("Nohemi-Black", size: rank == 1 ? 44 : rank == 2 ? 32 : 26))
                    .foregroundStyle(rank == 1 ? Color(hex: "1A0535") : .white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .frame(height: blockHeight)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: rank == 1 ? Color.mustardYellow.opacity(0.35) : .clear, radius: 20, y: -6)
    }

    // MARK: - Others

    private var othersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ET LES AUTRES…")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.40))
                Spacer()
                Text("\(sorted.count - 3)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.40))
            }

            VStack(spacing: 6) {
                ForEach(Array(sorted.dropFirst(3).enumerated()), id: \.element.id) { index, player in
                    othersRow(rank: index + 4, player: player)
                }
            }
        }
        .padding(.bottom, 24)
    }

    private func othersRow(rank: Int, player: Player) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 18, alignment: .center)

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(.white)
                )

            Text(player.name)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Text("\(player.score)")
                .font(.nohemi(.subheadline, weight: .black))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var footerButtons: some View {
        HStack(spacing: 10) {
            Button {
                router.popToRoot()
            } label: {
                Text("Quitter")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button {
                masterFlowVM.resetForNewGame()
                router.popToRoot()
            } label: {
                Text("Nouvelle partie")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: Color.greenButtonLeading.opacity(0.32), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 12)
        .background(
            LinearGradient(
                colors: [Color(hex: "1A0535").opacity(0), Color(hex: "1A0535")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
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
