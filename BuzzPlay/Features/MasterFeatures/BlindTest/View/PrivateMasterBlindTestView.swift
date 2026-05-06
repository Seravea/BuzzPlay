//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//

import SwiftUI

struct PrivateMasterBlindTestView: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel

    @State private var showValidationOverlay = false
    @State private var validationPoints = 0
    @State private var validationTeamName = ""

    private enum Screen: Equatable { case search, songList, playing }

    private var currentScreen: Screen {
        if blindTestVM.isGameActive { return .playing }
        if !blindTestVM.allSongs.isEmpty { return .songList }
        return .search
    }

    private let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            BlindTestSearchScreen(blindTestVM: blindTestVM)
                .offset(x: currentScreen == .search ? 0 : -screenWidth)
                .opacity(currentScreen == .search ? 1 : 0)

            BlindTestSongListScreen(blindTestVM: blindTestVM) {
                withAnimation {
                    blindTestVM.allSongs = []
                    blindTestVM.playlists = []
                    blindTestVM.selectedMusic = nil
                }
            }
            .offset(x: currentScreen == .songList ? 0 : (currentScreen == .search ? screenWidth : -screenWidth))
            .opacity(currentScreen == .songList ? 1 : 0)

            BlindTestActiveScreen(
                blindTestVM: blindTestVM,
                onValidate: handleValidate,
                onReject: { blindTestVM.rejectAnswer() }
            )
            .offset(x: currentScreen == .playing ? 0 : screenWidth)
            .opacity(currentScreen == .playing ? 1 : 0)

            if showValidationOverlay {
                QuizValidationOverlay(points: validationPoints, teamName: validationTeamName)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.45, bounce: 0.05), value: currentScreen)
        .onAppear {
            Task {
                await blindTestVM.appleMusicService.setupAppleMusic()
                await blindTestVM.updateCatalogPlaybackCapability()
            }
        }
        .alert("Information", isPresented: $blindTestVM.showSubscriptionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(blindTestVM.subscriptionAlertMessage)
        }
        .alert("Erreur", isPresented: Binding(
            get: { blindTestVM.fetchError != nil },
            set: { if !$0 { blindTestVM.fetchError = nil } }
        )) {
            Button("OK", role: .cancel) { blindTestVM.fetchError = nil }
        } message: {
            Text(blindTestVM.fetchError ?? "")
        }
    }

    private func handleValidate(points: Int) {
        validationPoints = points
        validationTeamName = blindTestVM.playerHasBuzz?.name ?? ""
        withAnimation(.spring(duration: 0.3, bounce: 0.2)) { showValidationOverlay = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            blindTestVM.validateAnswer(points: points)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.easeOut(duration: 0.3)) { showValidationOverlay = false }
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundAppView())
}
