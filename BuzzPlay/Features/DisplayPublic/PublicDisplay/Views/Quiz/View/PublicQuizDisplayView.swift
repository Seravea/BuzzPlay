//
//  PublicQuizDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicQuizDisplayView: View {
    var state: PublicQuizState
    var timer: String
    var timerReady: Bool = true

    var body: some View {
        VStack(spacing: 14) {
            // Timer badge — masqué avant réception du 1er timerStarted (#A4)
            TimerBadge(time: timerReady ? timer : "—")
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Question Card — masquée jusqu'à la fin du premier countdown
            if state.isQuestionRevealed {
                VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                    Text("QUESTION")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(0.8)

                    Text(state.question.title)
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                .transition(.opacity)
            } else {
                VStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "hourglass")
                        .textStyle(Typography.sectionTitleSoft)
                        .foregroundStyle(Color.textDim)
                    Text("Préparez-vous…")
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(.white.opacity(0.06), lineWidth: 1))
                .transition(.opacity)
            }

            // Answers Section (only if revealed)
            if state.isAnswerRevealed {
                VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                    Text("RÉPONSE")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(0.8)

                    Text(state.question.answers.first ?? "N/A")
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(Color.mustardYellow)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(Color.mustardYellow.opacity(0.3), lineWidth: 1))
                .transition(.scale.combined(with: .opacity))
            }

            // #header-bt — card "A BUZZÉ" retirée (harmonisé avec le BlindTest) : le label
            // "X a buzzé" sous le buzzer suffit, la zone ne saute plus au buzz.
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.top, 0)
        .animation(.spring(duration: 0.4), value: state)
    }
}

#Preview {
    let samplePlayers = [
        Player(name: "Team 1", teamColor: .greenGame, score: 240),
        Player(name: "Team 2", teamColor: .blueGame, score: 240),
    ]
    PublicQuizDisplayView(
        state: PublicQuizState(
            question: QuizSamples.music2000s.questions[3],
            setTitle: QuizSamples.music2000s.title,
            formattedTime: "00:00",
            buzzingPlayer: samplePlayers[1],
            isAnswerRevealed: false,
            isHintVisible: false,
            countdownPhase: .hidden,
            isQuestionRevealed: true
        ),
        timer: "00:00"
    )
}
