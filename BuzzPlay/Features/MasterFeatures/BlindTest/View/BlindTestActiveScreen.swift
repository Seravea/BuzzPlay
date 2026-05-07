//
//  BlindTestActiveScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestActiveScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var buzzedPlayer: Player? { blindTestVM.playerHasBuzz }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 14) {
                timerHero
                songCard
                scoresSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            if buzzedPlayer != nil {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .transition(.opacity)
            }

            if let player = buzzedPlayer {
                BlindTestBuzzSheet(
                    player: player,
                    reactionTime: blindTestVM.formattedTime,
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }

            if blindTestVM.roundCountdownPhase != .hidden {
                MasterCountdownOverlay(phase: blindTestVM.roundCountdownPhase)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.05), value: buzzedPlayer != nil)
        .animation(.easeInOut(duration: 0.25), value: blindTestVM.roundCountdownPhase)
    }

    private var timerHero: some View {
        HStack {
            Text(blindTestVM.formattedTime)
                .font(.nohemi(.largeTitle, weight: .extraBold))
                .foregroundStyle(buzzedPlayer != nil ? Color(hex: "#F6339A") : .mustardYellow)
                .tracking(3)
                .contentTransition(.numericText())
                .animation(.default, value: blindTestVM.formattedTime)
            Spacer()
            Text(buzzedPlayer != nil ? "PAUSÉ" : (blindTestVM.isPlaying ? "EN COURS" : "TERMINÉ"))
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: 18))
    }

    private var songCard: some View {
        HStack(spacing: 14) {
            AsyncImage(url: blindTestVM.selectedMusic?.postertURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.5))
                    )
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text("EN COURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)
                Text(blindTestVM.selectedMusic?.title ?? "—")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
                Text(blindTestVM.selectedMusic?.artist ?? "—")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if blindTestVM.isPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .font(.title2)
                    .foregroundStyle(Color.mustardYellow)
            }
        }
        .padding(12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    private var scoresSection: some View {
        let players = blindTestVM.gameVM.players.sorted { $0.score > $1.score }
        let maxScore = max(players.map(\.score).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 8) {
            Text("CLASSEMENT EN DIRECT")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(0.8)
                .padding(.leading, 2)

            ForEach(players) { player in
                QuizScoreRow(player: player, maxScore: maxScore)
            }

            if blindTestVM.isPlaying && buzzedPlayer == nil {
                HStack(spacing: 10) {
                    RadarPulseView()
                    Text("En attente d'un buzz…")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestActiveScreen(
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()),
            onValidate: { _ in },
            onReject: {}
        )
    }
}
