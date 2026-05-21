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
            ToolbarItem(placement: .topBarLeading) {
                if blindTestViewModel.isGameActive {
                    Button {
                        withAnimation { blindTestViewModel.cancelRound() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    Button {
                        blindTestViewModel.gameVM.finishGameSection(.blindTest)
                        router.path.removeLast()
                        if blindTestViewModel.gameVM.isGameComplete {
                            router.push(.scoreMaster)
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Fin de Blind Test")
                                .font(.nohemi(.subheadline, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            // Abonnement Apple Music (écran recherche uniquement, sans catalogue disponible)
            ToolbarItem(placement: .topBarLeading) {
                if blindTestViewModel.allSongs.isEmpty && !blindTestViewModel.canPlayCatalogContent {
                    Button {
                        showSubscriptionOffer = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.orange)
                            Text("Gratuit · ~15 sec")
                                .font(.nohemi(.subheadline, weight: .medium))
                                .foregroundStyle(.white)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: blindTestViewModel.gameVM.connectedPlayersCount,
                    total: blindTestViewModel.gameVM.totalPlayersCount
                )
            }
        }
        .navigationBarBackButtonHidden(!blindTestViewModel.allSongs.isEmpty || blindTestViewModel.isGameActive)
    }
}

#Preview {
    NavigationStack {
        BlindTestMasterView(blindTestViewModel: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
    }
}
