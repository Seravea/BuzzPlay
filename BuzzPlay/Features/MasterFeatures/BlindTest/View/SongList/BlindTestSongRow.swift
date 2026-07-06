//
//  BlindTestSongRow.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestSongRow: View {
    let number: Int
    let song: BlindTestSong
    let isPlayed: Bool
    /// Position 1-based dans la file (nil = pas en file).
    let queuePosition: Int?
    let action: () -> Void

    private var isQueued: Bool { queuePosition != nil }

    var body: some View {
        Button(action: action) {
            HStack(spacing: BuzzSpacing.md) {
                // Artwork avec badge played en overlay
                ZStack {
                    AsyncImage(url: song.postertURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        badgeColor
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.xs))

                    if isPlayed {
                        RoundedRectangle(cornerRadius: BuzzRadius.xs)
                            .fill(.black.opacity(0.55))
                            .frame(width: 56, height: 56)
                        Image(systemName: "checkmark")
                            .textStyle(Typography.footnoteBold)
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(song.artist)
                        .font(.nohemi(.caption2, weight: .medium))
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(song.releaseYearString)
                    .font(.nohemi(.caption2, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))

                if let pos = queuePosition, !isPlayed {
                    // Badge numéroté = ordre de passage dans la file (norme BuzzCountBadge).
                    BuzzCountBadge("\(pos)")
                } else if !isPlayed {
                    Image(systemName: "plus.circle")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.textFaint)
                }
            }
            .padding(BuzzSpacing.sm)
            .background(.white.opacity(isQueued ? 0.1 : 0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .opacity(isPlayed ? 0.5 : 1)
        }
        .disabled(isPlayed)
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        if isPlayed  { return Color.greenButtonLeading.opacity(0.25) }
        if isQueued { return Color.mustardYellow.opacity(0.35) }
        return .white.opacity(0.1)
    }

    private var borderColor: Color {
        if isQueued { return Color.mustardYellow.opacity(0.4) }
        if isPlayed   { return Color.greenButtonLeading.opacity(0.25) }
        return .white.opacity(0.08)
    }
}
