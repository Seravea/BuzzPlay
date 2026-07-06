//
//  QuizQuestionListScreen.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Screen 1: Question List

struct QuizQuestionListScreen: View {
    @Bindable var quizMasterVM: QuizMasterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            listHeader
            questionList
        }
    }

    private var inviteButton: some View {
        let invited = quizMasterVM.hasInvitedPlayers
        return Button {
            quizMasterVM.invitePlayers()  // #invite-auto — ré-invite manuelle (joueur en retard)
        } label: {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: invited ? "checkmark.circle.fill" : "person.wave.2.fill")
                    .textStyle(Typography.footnoteBold)
                Text(invited ? "Joueurs invités" : "Inviter les joueurs")
                    .font(.nohemi(.subheadline, weight: .bold))
                Spacer()
                Text(invited ? "Appuyer pour ré-inviter" : "Auto — ou appuyer ici")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(invited ? 0.5 : 0.65))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .fill(invited
                          ? AnyShapeStyle(Color.white.opacity(0.10))
                          : AnyShapeStyle(LinearGradient(
                                colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                startPoint: .leading, endPoint: .trailing)))
            )
            .shadow(color: invited ? .clear : Color.greenButtonLeading.opacity(0.35), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.buzzFade, value: invited)
    }

    private var listHeader: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            // #invite-progress — avant l'invite : bouton vert (rare avec l'auto-invite) ;
            // une fois invité : barre « X/Y prêts » + bouton « Réinviter » (actif si manquants).
            if !quizMasterVM.hasInvitedPlayers {
                inviteButton
                    .padding(.bottom, 4)
            } else if !quizMasterVM.isPlaying && quizMasterVM.gameVM.totalPlayersCount > 0 {
                InviteProgressRow(ready: quizMasterVM.gameVM.readyAndConnectedCount,
                                  total: quizMasterVM.gameVM.totalPlayersCount,
                                  onReinvite: { quizMasterVM.invitePlayers() })
                    .padding(.bottom, 4)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quizMasterVM.quizSet.title)
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                        .foregroundStyle(.white)
                    Text("\(quizMasterVM.questions.count) questions · \(quizMasterVM.gameVM.players.count) équipes")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Text("\(quizMasterVM.questionsPassed.count)/\(quizMasterVM.questions.count) \(Image(systemName: BuzzIcon.checkSimple))")
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white)
                    .pillStyle(fill: .white.opacity(0.1), stroke: nil, compact: true, trailingIcon: true)
            }
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 3)
                    let progress = quizMasterVM.questions.isEmpty ? 0.0 :
                        Double(quizMasterVM.questionsPassed.count) / Double(quizMasterVM.questions.count)
                    Capsule()
                        .fill(LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.spring(), value: quizMasterVM.questionsPassed.count)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.top, BuzzSpacing.lg)     // #header-air — ne pas coller à la nav bar
        .padding(.bottom, 14)
    }

    private var questionList: some View {
        ScrollView {
            LazyVStack(spacing: BuzzSpacing.sm) {
                ForEach(Array(quizMasterVM.questions.enumerated()), id: \.element.id) { index, question in
                    QuizQuestionRow(
                        number: index + 1,
                        question: question,
                        isDone: quizMasterVM.questionsPassed.contains(question),
                        isDisabled: quizMasterVM.quizButtonDisabled(question: question)
                    ) {
                        withAnimation { quizMasterVM.selectQuestion(question) }
                    }
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.bottom, BuzzSpacing.xl)
        }
    }
}
