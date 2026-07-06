//
//  BlindTestPlaylistRow.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Playlist Row

struct BlindTestPlaylistRow: View {
    let playlist: BlindTestPlaylist
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AsyncImage(url: playlist.artworkURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .overlay(
                            Image(systemName: "music.note.list")
                                .textStyle(Typography.cardTitle)
                                .foregroundStyle(.white.opacity(0.8))
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.xs))

                VStack(alignment: .leading, spacing: 3) {
                    Text(playlist.name)
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    if let curator = playlist.curator {
                        Text(curator)
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(Color.textMuted)
                    }
                }

                Spacer()

                if let count = playlist.trackCount {
                    Text("\(count) titres")
                        .font(.nohemi(.caption, weight: .semiBold))
                        .foregroundStyle(Color.textMuted)
                }

                Image(systemName: "chevron.right")
                    .textStyle(Typography.footnoteEM)
                    .foregroundStyle(Color.textFaint)
            }
            .padding(BuzzSpacing.sm)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.08), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}
