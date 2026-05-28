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
            withAnimation(.easeOut(duration: 0.3)) {
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
            quizMasterVM.hasInvitedPlayers = true
            quizMasterVM.gameVM.broadcastGameLaunch(.quiz)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: invited ? "checkmark.circle.fill" : "person.wave.2.fill")
                    .font(.system(size: 13, weight: .bold))
                Text(invited ? "Joueurs invités" : "Inviter les joueurs")
                    .font(.nohemi(.subheadline, weight: .bold))
                Spacer()
                Text(invited ? "Prêts à buzzer" : "Obligatoire avant de jouer")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(invited ? 0.5 : 0.65))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(invited
                          ? AnyShapeStyle(Color.white.opacity(0.10))
                          : AnyShapeStyle(LinearGradient(
                                colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                startPoint: .leading, endPoint: .trailing)))
            )
            .shadow(color: invited ? .clear : Color.greenButtonLeading.opacity(0.35), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: invited)
    }

    private var listHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Bouton "Inviter les joueurs" — obligatoire avant de pouvoir sélectionner une question
            inviteButton
                .padding(.bottom, 4)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quizMasterVM.quizSet.title)
                        .font(.nohemi(.title2, weight: .extraBold))
                        .foregroundStyle(.white)
                    Text("\(quizMasterVM.questions.count) questions · \(quizMasterVM.gameVM.players.count) équipes")
                        .font(.nohemi(.subheadline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text("\(quizMasterVM.questionsPassed.count)/\(quizMasterVM.questions.count) ✓")
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
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    private var questionList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
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
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
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
            HStack(spacing: 12) {
                // Number badge with difficulty color
                Text("\(number)")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(question.title)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        if question.questionType == .rebus {
                            Text("🎭 Rébus")
                                .font(.nohemi(.caption2, weight: .semiBold))
                                .foregroundStyle(Color(hex: "#AD46FF").opacity(0.9))
                        } else if let theme = question.theme {
                            Text(theme)
                                .font(.nohemi(.caption2, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.greenButtonLeading)
                } else if !isDisabled {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.25))
                }
            }
            .padding(14)
            .background(.white.opacity(isDone ? 0.06 : 0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
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

            VStack(spacing: 16) {
                ZStack {
                    // Glow circles
                    Circle()
                        .fill(Color(hex: "#7DFFA0").opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 16)

                    VStack(spacing: 12) {
                        Text("✅")
                            .font(.system(size: 56))
                        Text("+\(points)")
                            .font(.nohemi(.largeTitle, weight: .black))
                            .foregroundStyle(Color(hex: "#7DFFA0"))
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
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(32)
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
