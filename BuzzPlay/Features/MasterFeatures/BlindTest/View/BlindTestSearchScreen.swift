//
//  BlindTestSearchScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

// MARK: - Category data

private struct CategoryItem: Identifiable {
    let id = UUID()
    let label: String
    let query: String
    let icon: String
    let colors: [Color]
}

private let generations: [CategoryItem] = [
    .init(label: "70s", query: "années 70",   icon: "waveform.circle.fill",  colors: [Color.coral, Color.crimson]),
    .init(label: "80s", query: "années 80",   icon: "radio.fill",            colors: [Color.violet, Color.buzzIndigo]),
    .init(label: "90s", query: "années 90",   icon: "opticaldisc",           colors: [Color.royalBlue, Color.skyBlue]),
    .init(label: "00s", query: "années 2000", icon: "music.note.list",       colors: [Color.burnOrange, Color.amberWarm]),
    .init(label: "10s", query: "années 2010", icon: "headphones",            colors: [Color.oceanBlue, Color.deepDark]),
    .init(label: "20s", query: "années 2020", icon: "dot.radiowaves.left.and.right", colors: [Color.teal, Color.emerald]),
]

private let genres: [CategoryItem] = [
    .init(label: "Pop",        query: "pop hits",           icon: "star.fill",   colors: [Color.vibrantPink, Color.fuchsia]),
    .init(label: "Rock",       query: "rock",               icon: "bolt.fill",   colors: [Color.scarlet, Color.burnOrange]),
    .init(label: "Hip-Hop",    query: "hip hop",            icon: "mic.fill",    colors: [Color.buzzIndigo, Color.softIndigo]),
    .init(label: "Électro",    query: "electro dance",      icon: "waveform",    colors: [Color.skyBlue, Color.softIndigo]),
    .init(label: "R&B · Soul", query: "r&b soul",           icon: "heart.fill",  colors: [Color.amberWarm, Color.errorLight]),
    .init(label: "Variété FR", query: "variété française",  icon: "music.note",  colors: [Color.royalBlue, Color.buzzIndigo]),
    .init(label: "K-Pop",      query: "k-pop",              icon: "crown.fill",  colors: [Color.vibrantPink, Color.buzzIndigo]),
    .init(label: "Latino",     query: "latino hits",        icon: "flame.fill",  colors: [Color.tangerine, Color.errorLight]),
]

// MARK: - Main View

struct BlindTestSearchScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onSubscribeTap: () -> Void

    @FocusState private var searchFocused: Bool
    @State private var searchText = ""
    @State private var showSearchBar = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Apple Music banner
            appleMusicBanner
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Lancer le Blind Test — invite les players sur leur buzzer
            launchButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Inline search bar (slides in from top)
            if showSearchBar {
                searchBarRow
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Content area
            if blindTestVM.isFetching {
                loadingView
            } else if !blindTestVM.playlists.isEmpty {
                resultsSection
            } else {
                categoriesSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            if !showSearchBar && blindTestVM.playlists.isEmpty && !blindTestVM.isFetching {
                bottomSearchCTA
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .animation(.spring(duration: 0.3, bounce: 0.05), value: showSearchBar)
        .animation(.spring(duration: 0.3, bounce: 0.05), value: blindTestVM.playlists.isEmpty)
        .animation(.spring(duration: 0.3, bounce: 0.05), value: blindTestVM.isFetching)
    }

    // MARK: Launch Button

    private var launchButton: some View {
        let invited = blindTestVM.hasInvitedPlayers
        return Button {
            blindTestVM.hasInvitedPlayers = true
            blindTestVM.gameVM.broadcastGameLaunch(.blindTest)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: invited ? "checkmark.circle.fill" : "person.wave.2.fill")
                    .font(.system(size: 13, weight: .bold))
                Text(invited ? "Joueurs invités" : "Inviter les joueurs")
                    .font(.nohemi(.subheadline, weight: .bold))
                Spacer()
                Text(invited ? "Prêts à buzzer" : "Obligatoire avant de jouer")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(invited ? 0.5 : 0.65))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(invited
                          ? AnyShapeStyle(Color.white.opacity(0.10))
                          : AnyShapeStyle(LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                                         startPoint: .leading, endPoint: .trailing)))
            )
            .shadow(color: invited ? .clear : Color.greenButtonLeading.opacity(0.35), radius: 10, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: invited)
    }

    // MARK: Apple Music Banner

    private var appleMusicBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: blindTestVM.canPlayCatalogContent ? "music.note" : "music.note")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(blindTestVM.canPlayCatalogContent ? Color.greenButtonLeading : Color.mustardYellow)

            if blindTestVM.canPlayCatalogContent {
                (Text("Titre entier · ").foregroundStyle(.white)
                 + Text("Apple Music").foregroundStyle(.white.opacity(0.55)))
                    .font(.nohemi(.caption, weight: .bold))
            } else {
                (Text("Preview ").foregroundStyle(.white.opacity(0.55))
                 + Text("15s").foregroundStyle(.white).bold()
                 + Text(" · Titre entier avec ").foregroundStyle(.white.opacity(0.55))
                 + Text("Apple Music").foregroundStyle(.white).bold())
                    .font(.nohemi(.caption, weight: .regular))
            }

            Spacer(minLength: 4)

            if !blindTestVM.canPlayCatalogContent {
                Button(action: onSubscribeTap) {
                    Text("S'abonner")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                           startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: Inline Search Bar

    private var searchBarRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))

                TextField("", text: $searchText,
                          prompt: Text("Nom d'une playlist…").foregroundStyle(.white.opacity(0.35)))
                    .font(.nohemi(.body))
                    .foregroundStyle(.white)
                    .focused($searchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit { doSearch() }

                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.mustardYellow.opacity(0.5), lineWidth: 1)
            )

            Button("Annuler") {
                showSearchBar = false
                searchText = ""
                searchFocused = false
            }
            .font(.nohemi(.body, weight: .semiBold))
            .foregroundStyle(.white.opacity(0.7))
            .buttonStyle(.plain)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { searchFocused = true }
        }
    }

    // MARK: Categories

    private var categoriesSection: some View {
        ScrollView() {
            VStack(alignment: .leading, spacing: 24) {
                categoryRow(label: "GÉNÉRATION", items: generations)
                categoryRow(label: "GENRE", items: genres)
            }
            .padding(.bottom, 80)
        }
    }

    private func categoryRow(label: String, items: [CategoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)
                .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        CategoryCard(item: item) { doSearch(query: item.query) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                let n = blindTestVM.playlists.count
                Text("\(n) PLAYLIST\(n > 1 ? "S" : "") TROUVÉE\(n > 1 ? "S" : "")")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)

                Spacer()

                Button {
                    withAnimation { blindTestVM.playlists = [] }
                    showSearchBar = false
                    searchText = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

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

    // MARK: Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView().scaleEffect(1.2).tint(.white)
            Text("Recherche en cours…")
                .font(.nohemi(.subheadline, weight: .regular))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Bottom CTA

    private var bottomSearchCTA: some View {
        Button {
            withAnimation { showSearchBar = true }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
                Text("Chercher une playlist précise…")
                    .font(.nohemi(.body, weight: .semiBold))
                    .foregroundStyle(.white.opacity(0.65))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private func doSearch(query: String? = nil) {
        let q = query ?? searchText
        guard !q.isEmpty else { return }
        searchFocused = false
        withAnimation { showSearchBar = false }
        withAnimation { blindTestVM.playlists = [] }
        Task { await blindTestVM.search(query: q) }
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let item: CategoryItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    LinearGradient(colors: item.colors,
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Image(systemName: item.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                }
                .frame(width: 74, height: 74)

                Text(item.label)
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

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
        BlindTestSearchScreen(
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()),
            onSubscribeTap: {}
        )
    }
}
