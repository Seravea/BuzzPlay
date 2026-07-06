//
//  AppleMusicBanner.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Apple Music Banner

struct AppleMusicBanner: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onSubscribeTap: () -> Void

    // #12 — feedback pendant la latence d'ouverture de la sheet d'abonnement Apple Music
    @State private var isSubscribing = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: blindTestVM.canPlayCatalogContent ? "music.note" : "music.note")
                .textStyle(Typography.footnoteEM)
                .foregroundStyle(blindTestVM.canPlayCatalogContent ? Color.greenButtonLeading : Color.mustardYellow)

            if blindTestVM.canPlayCatalogContent {
                (Text("Titre entier · ").foregroundStyle(.white)
                 + Text("Apple Music").foregroundStyle(Color.textSecondary))
                    .font(.nohemi(.caption, weight: .bold))
            } else {
                // #v1-review — les previews jouent jusqu'au bout (~30s, pas de coupe) :
                // le Blind Test est 100 % jouable SANS abonnement (important pour App Review).
                (Text("Extraits ").foregroundStyle(Color.textSecondary)
                 + Text("30s inclus").foregroundStyle(.white).bold()
                 + Text(" · Titre entier avec ").foregroundStyle(Color.textSecondary)
                 + Text("Apple Music").foregroundStyle(.white).bold())
                    .font(.nohemi(.caption, weight: .regular))
            }

            Spacer(minLength: 4)

            if !blindTestVM.canPlayCatalogContent {
                Button {
                    isSubscribing = true
                    onSubscribeTap()
                    // La sheet StoreKit/MusicKit met un instant à s'ouvrir → on relâche le
                    // spinner après un court délai (le bouton disparaît si l'abonnement passe).
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { isSubscribing = false }
                } label: {
                    Group {
                        if isSubscribing {
                            ProgressView().controlSize(.mini).tint(.white)
                        } else {
                            Text("S'abonner")
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(minWidth: 60)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                       startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
                .disabled(isSubscribing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}
