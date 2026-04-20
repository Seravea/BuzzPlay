//
//  BlindTestMasterView.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestMasterView: View {
    @Bindable var blindTestViewModel: BlindTestMasterViewModel
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
                // Bouton retour vers la liste des titres (manche active uniquement)
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
                    } else if !blindTestViewModel.canPlayCatalogContent {
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
                        connected: blindTestViewModel.gameVM.connectedTeamsCount,
                        total: blindTestViewModel.gameVM.totalTeamsCount
                    )
                }
            }
    }
}

#Preview {
    NavigationStack {
        BlindTestMasterView(blindTestViewModel: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
    }
}
