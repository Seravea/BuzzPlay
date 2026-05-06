//
//  BlindTestSearchScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestSearchScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    @FocusState private var searchFocused: Bool
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Blind Test")
                    .font(.nohemi(.title2, weight: .extraBold))
                    .foregroundStyle(.white)
                Text("Cherche une playlist Apple Music")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Barre de recherche
            HStack(spacing: 10) {
                TextField("", text: $searchText,
                          prompt: Text("Nom d'une playlist…").foregroundStyle(.white.opacity(0.35)))
                    .font(.nohemi(.body))
                    .foregroundStyle(.white)
                    .focused($searchFocused)
                    .padding(12)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.12), lineWidth: 1))

                Button {
                    searchFocused = false
                    withAnimation { blindTestVM.playlists = [] }
                    Task { await blindTestVM.search(query: searchText) }
                } label: {
                    Text("Chercher")
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.yellowLeading, .yellowTrailing],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Contenu
            if blindTestVM.isFetching {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView().scaleEffect(1.3).tint(.white)
                    Spacer()
                }
                Spacer()
            } else if blindTestVM.playlists.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.2))
                    Text("Lance une recherche\npour trouver une playlist")
                        .font(.nohemi(.body))
                        .foregroundStyle(.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(blindTestVM.playlists) { playlist in
                            BlindTestPlaylistRow(playlist: playlist) {
                                Task { await blindTestVM.selectPlaylist(playlist) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

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
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.8))
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(playlist.name)
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    if let curator = playlist.curator {
                        Text(curator)
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                Spacer()

                if let count = playlist.trackCount {
                    Text("\(count) titres")
                        .font(.nohemi(.caption, weight: .semiBold))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .padding(8)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestSearchScreen(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
    }
}
