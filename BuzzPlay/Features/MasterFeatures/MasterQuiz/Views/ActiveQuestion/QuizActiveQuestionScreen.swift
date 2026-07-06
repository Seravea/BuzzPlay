//
//  QuizMasterQuestionView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Screen 2: Active Question

struct QuizActiveQuestionScreen: View {
    @Bindable var quizMasterVM: QuizMasterViewModel
    let onValidate: (Int) -> Void
    let onReject: () -> Void
    let onSkip: () -> Void

    var buzzedPlayer: Player? { quizMasterVM.playerHasBuzz }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 14) {
                timerHero
                questionCard
                answersSection
                scoresSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BuzzSpacing.xl)

            if buzzedPlayer != nil {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .transition(.opacity)
            }

            if let player = buzzedPlayer {
                QuizBuzzSheet(
                    player: player,
                    reactionTime: quizMasterVM.formattedTime,
                    buzzStartedAt: quizMasterVM.buzzStartedAt,
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }

            if quizMasterVM.roundCountdownPhase != .hidden {
                CountdownOverlay(phase: quizMasterVM.roundCountdownPhase, label: "Lis la question à voix haute", backgroundOpacity: 0.30)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.05), value: buzzedPlayer != nil)
        .animation(.buzzFade, value: quizMasterVM.roundCountdownPhase)
        // #D11/#C3 — empêcher la veille iPhone pendant la partie
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // MARK: Timer

    private var timerHero: some View {
        HStack {
            Text(quizMasterVM.formattedTime)
                .font(.nohemi(.largeTitle, weight: .extraBold)).titleTracking()
                .foregroundStyle(buzzedPlayer != nil ? Color.purpleTrailing : Color.mustardYellow)
                .tracking(3)
                .monospacedDigit()   // largeur de chiffre fixe → le chrono ne tremble pas
                .nohemiBadgeNudge(fontSize: 34)   // Nohemi sied haut → recentre le chrono dans la card
                // pas de contentTransition/animation : mise à jour sans roulement, 0 mouvement
            Spacer()
            Text(buzzedPlayer != nil ? "PAUSÉ" : "EN COURS")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
    }

    // MARK: Question Card

    private var questionCard: some View {
        let question = quizMasterVM.currentQuestion
        let isRebus = question?.questionType == .rebus

        return VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack(spacing: BuzzSpacing.sm) {
                Text("QUESTION")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(0.8)
                if isRebus {
                    Label("RÉBUS", systemImage: "theatermasks.fill")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.purpleLeading)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purpleLeading.opacity(0.15), in: Capsule())
                }
            }
            if let q = question {
                Text(q.title)
                    .font(.nohemi(.title3, weight: .bold)).titleTracking()
                    .foregroundStyle(.white)

                if isRebus && !q.indices.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(q.indices, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 44))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(
            isRebus ? Color.purpleLeading.opacity(0.25) : .white.opacity(0.1),
            lineWidth: 1
        ))
    }

    // MARK: Answers

    private var answersSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("RÉPONSES")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(0.8)
                .padding(.leading, 2)

            if let answers = quizMasterVM.currentQuestion?.answers, !answers.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BuzzSpacing.sm) {
                    ForEach(answers, id: \.self) { answer in
                        Text(answer)
                            .font(.nohemi(.subheadline, weight: .semiBold))
                            .foregroundStyle(Color.greenGlow)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, BuzzSpacing.md)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.greenButtonLeading.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: BuzzRadius.md).strokeBorder(Color.greenButtonLeading.opacity(0.25), lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: Scores + Waiting Radar

    private var scoresSection: some View {
        let players = quizMasterVM.gameVM.players.sorted { $0.score > $1.score }
        let maxScore = max(players.map(\.score).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("CLASSEMENT EN DIRECT")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(Color.textDim)
                .tracking(0.8)
                .padding(.leading, 2)

            ForEach(players) { player in
                QuizScoreRow(player: player, maxScore: maxScore)
            }

            if quizMasterVM.playerHasBuzz == nil {
                HStack {
                    HStack(spacing: 10) {
                        RadarPulseView()
                        Text("En attente d'un buzz…")
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                    Spacer()
                    Button(action: onSkip) {
                        HStack(spacing: 5) {
                            Text("Passer")
                                .font(.nohemi(.caption, weight: .bold))
                            Image(systemName: "forward.end.fill")
                                .textStyle(Typography.caption2)
                        }
                        .foregroundStyle(Color.textSoft)
                        .padding(.horizontal, BuzzSpacing.md)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.08), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        QuizActiveQuestionScreen(
            quizMasterVM: QuizMasterViewModel(
                gameVM: MasterFlowViewModel(),
                quizSet: QuizSamples.music2000s
            ),
            onValidate: { _ in },
            onReject: {},
            onSkip: {}
        )
    }
}
