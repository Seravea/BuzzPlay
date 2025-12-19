//
//  PlaylistCard.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/12/2025.
//

import SwiftUI
import MusicKit

struct PlaylistCard: View {
    var playlist: BlindTestPlaylist
    var body: some View {
        HStack {
            AsyncImage(url: playlist.artworkURL) { PosterImage in
                PosterImage
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading) {
                Text(playlist.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let trackCount = playlist.trackCount, let curator = playlist.curator {
                    Text("\(trackCount) musiques")
                    Text("par \(curator)")
                }
                
                
            }
        }
        .frame(height: 80)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.thinMaterial)
        }
    }
}

#Preview {
    PlaylistCard(playlist: BlindTestPlaylist(id: "123456789", name: "C'est une playlist qui a un grand nom et il faut qu'il rentre ce serait tip-top", curator: "Romain Poyard", artworkURL: nil, trackCount: 100))
}
