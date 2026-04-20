//
//  BlindTestMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI
import MusicKit

struct BlindTestMasterView: View {
    @Bindable var blindTestViewModel: BlindTestMasterViewModel
    @Bindable var ambiantSoundViewModel = AmbiantSoundViewModel()
    @State private var showSubscriptionOffer = false

    var body: some View {
        GeometryReader { geo in
            HStack {
                PrivateMasterBlindTestView(ambiantaudioPlayerVM: ambiantSoundViewModel, blindTestVM: blindTestViewModel)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BackgroundAppView())
            .musicSubscriptionOffer(isPresented: $showSubscriptionOffer, options: .default)
            .onChange(of: showSubscriptionOffer) { _, isPresented in
                if !isPresented {
                    Task { await blindTestViewModel.updateCatalogPlaybackCapability() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !blindTestViewModel.canPlayCatalogContent {
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
}

#Preview {
    BlindTestMasterView(blindTestViewModel: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
}
