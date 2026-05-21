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

    var body: some View {
        PrivateMasterBlindTestView(blindTestVM: blindTestViewModel)
            .musicSubscriptionOffer(isPresented: $showSubscriptionOffer, options: .default)
            .onChange(of: showSubscriptionOffer) { _, isPresented in
                if !isPresented {
                    Task { await blindTestViewModel.updateCatalogPlaybackCapability() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if blindTestViewModel.isGameActive {
                        // Manche active → annuler la chanson en cours
                        Button {
                            withAnimation { blindTestViewModel.cancelRound() }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    } else {
                        // Entre deux chansons → terminer la session Blind Test
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

                // Abonnement Apple Music (affiché sur écran recherche uniquement quand pas de catalogue)
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
