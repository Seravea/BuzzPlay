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
                footerButtons
            }
        }
        .navigationBarBackButtonHidden()
        .appDefaultTextStyle(Typography.body)
        .onAppear { masterFlowVM.collectUnspentNotes() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: BuzzSpacing.xs) {
            Text("PARTIE TERMINÉE")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color.mustardYellow)

            Text("Classement final")
                .font(.nohemi(.title, weight: .black))
                .foregroundStyle(.white)

            if masterFlowVM.notesRecoveredThisSession > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.uturn.left.circle.fill")
                        .textStyle(Typography.caption2)
                    Text("+\(masterFlowVM.notesRecoveredThisSession) Notes récupérées")
                        .font(.nohemi(.caption2, weight: .semiBold))
                }
                .foregroundStyle(Color.mustardYellow.opacity(0.75))
                .padding(.top, 4)
            }
        }
        .padding(.top, BuzzSpacing.md)
        .padding(.bottom, 28)
    }

    // MARK: - Podium

    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: BuzzSpacing.sm) {
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
            ? AnyShapeStyle(LinearGradient(colors: [Color.mustardYellow, Color.yellowTrailing], startPoint: .top, endPoint: .bottom))
            : AnyShapeStyle(.white.opacity(rank == 2 ? 0.12 : 0.08))
        let blockRadius: CGFloat = rank == 1 ? 14 : 10

        return VStack(spacing: 0) {
            if rank == 1 {
                Text("👑")
                    .textStyle(Typography.sectionTitle)
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
                .padding(.top, BuzzSpacing.sm)

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
                    .foregroundStyle(rank == 1 ? Color.sheetBg : Color.textSecondary)
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
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.sm)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
                .strokeBorder(.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var footerButtons: some View {
        HStack(spacing: 10) {
            Button {
                // #quit-teardown — prévient les Players, coupe heartbeat + session, reset l'état.
                masterFlowVM.leaveSessionAsMaster()
                router.popToRoot()
            } label: {
                Text("Quitter")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: BuzzRadius.lg)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button {
                masterFlowVM.resetForNewGame()
                router.popToRoot()
                router.push(.masterLobbyView)
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
                        in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    )
                    .shadow(color: Color.greenButtonLeading.opacity(0.32), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.bottom, BuzzSpacing.xxxl)
        .padding(.top, BuzzSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.sheetBg.opacity(0), Color.sheetBg],
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
