//
//  BlindTestMasterView.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestMasterView: View {
    @Bindable var blindTestViewModel: BlindTestMasterViewModel
    @EnvironmentObject private var router: Router
    @State private var showSubscriptionOffer = false
    @State private var showSectionComplete = false

    var body: some View {
        ZStack {
            PrivateMasterBlindTestView(
                blindTestVM: blindTestViewModel,
                onSubscribeTap: { showSubscriptionOffer = true }
            )
            .musicSubscriptionOffer(isPresented: $showSubscriptionOffer, options: .default)
            .onChange(of: showSubscriptionOffer) { _, isPresented in
                if !isPresented {
                    Task { await blindTestViewModel.updateCatalogPlaybackCapability() }
                }
            }

            if showSectionComplete {
                SectionCompleteOverlay(
                    gameTitle: "Blind Test",
                    roundsDone: blindTestViewModel.playedSongs.count,
                    roundsTotal: blindTestViewModel.roundsTotal
                )
                .transition(.opacity)
                .zIndex(200)
            }
        }
        .onChange(of: blindTestViewModel.shouldAutoFinish) { _, done in
            guard done else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.3)) { showSectionComplete = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                blindTestViewModel.gameVM.finishGameSection(.blindTest)
                router.path.removeLast()
                if blindTestViewModel.gameVM.isGameComplete { router.push(.scoreMaster) }
            }
        }
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: blindTestViewModel.gameVM.connectedPlayersCount,
                    total: blindTestViewModel.gameVM.totalPlayersCount
                )
            }
        }
        // #D10 — cacher le back SYSTÈME dès qu'on quitte l'écran Recherche : sur SongList,
        // l'écran a déjà son propre chevron retour (→ Recherche) → fini le double bouton.
        // Sur Recherche (1er écran), le back système reste = sortie du Blind Test.
        .navigationBarBackButtonHidden(blindTestViewModel.isGameActive || !blindTestViewModel.allSongs.isEmpty)
        .masterDarkNavBar()  // #8
    }
}

#Preview {
    NavigationStack {
        BlindTestMasterView(blindTestViewModel: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
    }
}
