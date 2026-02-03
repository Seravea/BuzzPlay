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
        VStack {
            AsyncImage(url: playlist.artworkURL) { PosterImage in
                PosterImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(12)
                
            } placeholder: {
                ProgressView()
                    .frame(height: 250)
            }

            VStack(alignment: .leading) {
                Text(playlist.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.nohemi(.title3, weight: .bold))
                if let trackCount = playlist.trackCount, let curator = playlist.curator {
                    Text("\(trackCount) morceaux")
                    Text("par \(curator)")
                }
                
                
            }
            
        }
        .frame(width: 250)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
                .opacity(0.1)
        }
        .foregroundStyle(.white)
        
    }
}

#Preview {
    PlaylistCard(playlist: BlindTestPlaylist(id: "123456789", name: "C'est une playlist qui a un grand nom et il faut qu'il rentre ce serait tip-top", curator: "Romain Poyard", artworkURL: nil, trackCount: 100))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundAppView()
        )
        .appDefaultTextStyle(Typography.body)
}
