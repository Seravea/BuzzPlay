//
//  QuizMasterListView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Main Container

struct QuizMasterListView: View {
    @Bindable var quizMasterVM: QuizMasterViewModel
    @EnvironmentObject private var router: Router

    @State private var showValidationOverlay = false
    @State private var validationPoints = 0
    @State private var validationPlayerName = ""
    @State private var showSectionComplete = false

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            // Screen 1 — Question list
            QuizQuestionListScreen(quizMasterVM: quizMasterVM)
                .offset(x: quizMasterVM.isPlaying ? -UIScreen.main.bounds.width : 0)
                .opacity(quizMasterVM.isPlaying ? 0 : 1)

            // Screen 2 — Active question
            QuizActiveQuestionScreen(
                quizMasterVM: quizMasterVM,
                onValidate: handleValidate,
                onReject: { quizMasterVM.rejectAnswer() },
                onSkip: { withAnimation { quizMasterVM.skipQuestion() } }
            )
            .offset(x: quizMasterVM.isPlaying ? 0 : UIScreen.main.bounds.width)
            .opacity(quizMasterVM.isPlaying ? 1 : 0)

            // Validation overlay — au-dessus des deux écrans
            if showValidationOverlay {
                QuizValidationOverlay(points: validationPoints, teamName: validationPlayerName)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            // Section complete overlay — au-dessus de tout
            if showSectionComplete {
                SectionCompleteOverlay(
                    gameTitle: "Quiz",
                    roundsDone: quizMasterVM.questionsPassed.count,
                    roundsTotal: quizMasterVM.questions.count
                )
                .transition(.opacity)
                .zIndex(200)
            }
        }
        .animation(.spring(duration: 0.45, bounce: 0.05), value: quizMasterVM.isPlaying)
        // #invite-auto — invite les joueurs dès l'entrée du Quiz (le bouton reste pour ré-inviter)
        .onAppear { quizMasterVM.autoInvitePlayersIfNeeded() }
        .onChange(of: quizMasterVM.shouldAutoFinish) { _, done in
            guard done else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.3)) { showSectionComplete = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                quizMasterVM.gameVM.finishGameSection(.quiz)
                // Pop quizMaster + quizThemeSelection → retour au hub
                router.path.removeLast()
                router.path.removeLast()
                if quizMasterVM.gameVM.isGameComplete { router.push(.scoreMaster) }
            }
        }
        .navigationBarBackButtonHidden(quizMasterVM.isPlaying)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: quizMasterVM.gameVM.connectedPlayersCount,
                    total: quizMasterVM.gameVM.totalPlayersCount
                )
            }
        }
        .masterDarkNavBar()  // #8
    }

    private func handleValidate(points: Int) {
        validationPoints = points
        validationPlayerName = quizMasterVM.gameVM.currentBuzzPlayer?.name ?? ""

        withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
            showValidationOverlay = true
        }
        // Déclenche le retour à la liste pendant que l'overlay est visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            quizMasterVM.validateAnswer(points: points)
        }
        // Fade out de l'overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.buzzSlide) {
                showValidationOverlay = false
            }
        }
    }
}

// MARK: - Screen 1: Question List

private struct QuizQuestionListScreen: View {
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
                HStack(spacing: 4) {
                    Text("\(quizMasterVM.questionsPassed.count)/\(quizMasterVM.questions.count)")
                    Image(systemName: BuzzIcon.checkSimple)
                }
                    .font(.nohemi(.caption, weight: .semiBold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.1), in: Capsule())
                    .foregroundStyle(.white)
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

// MARK: - Question Row

private struct QuizQuestionRow: View {
    let number: Int
    let question: QuizQuestion
    let isDone: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BuzzSpacing.md) {
                // Number badge with difficulty color
                Text("\(number)")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))

                VStack(alignment: .leading, spacing: 2) {
                    Text(question.title)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        if question.questionType == .rebus {
                            Label("Rébus", systemImage: "theatermasks.fill")
                                .font(.nohemi(.caption2, weight: .semiBold))
                                .foregroundStyle(Color.purpleLeading.opacity(0.9))
                        } else if let theme = question.theme {
                            Text(theme)
                                .font(.nohemi(.caption2, weight: .medium))
                                .foregroundStyle(Color.textMuted)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isDone {
                    Image(systemName: "checkmark")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.greenButtonLeading)
                } else if !isDisabled {
                    Image(systemName: "chevron.right")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.textFaint)
                }
            }
            .padding(14)
            .background(.white.opacity(isDone ? 0.06 : 0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(isDone ? Color.greenButtonLeading.opacity(0.25) : .white.opacity(0.08), lineWidth: 1.5)
            )
            .opacity(isDone ? 0.6 : 1)
        }
        .disabled(isDisabled || isDone)
        .opacity(isDisabled && !isDone ? 0.3 : 1)
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        if isDone { return .white.opacity(0.1) }
        guard let difficulty = question.difficulty else { return .white.opacity(0.1) }
        return difficulty.color.opacity(0.35)
    }
}

// MARK: - Validation Overlay

struct QuizValidationOverlay: View {
    let points: Int
    let teamName: String
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: BuzzSpacing.lg) {
                ZStack {
                    // Glow circles
                    Circle()
                        .fill(Color.greenGlow.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 16)

                    VStack(spacing: BuzzSpacing.md) {
                        Image(systemName: BuzzIcon.check)
                            .font(.system(size: 56))
                            .foregroundStyle(Color.greenGlow)
                        Text("+\(points)")
                            .font(.nohemi(.largeTitle, weight: .black)).titleTracking()
                            .foregroundStyle(Color.greenGlow)
                            .tracking(1)
                    }
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        scale = 1.0
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                Text(teamName)
                    .font(.nohemi(.body, weight: .semiBold))
                    .foregroundStyle(Color.textSoft)
            }
            .padding(BuzzSpacing.xxxl)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        QuizMasterListView(quizMasterVM: QuizMasterViewModel(
            gameVM: MasterFlowViewModel(),
            quizSet: QuizSamples.music2000s
        ))
    }
}
