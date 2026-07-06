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

// MARK: - Preview

#Preview {
    NavigationStack {
        QuizMasterListView(quizMasterVM: QuizMasterViewModel(
            gameVM: MasterFlowViewModel(),
            quizSet: QuizSamples.music2000s
        ))
    }
}
