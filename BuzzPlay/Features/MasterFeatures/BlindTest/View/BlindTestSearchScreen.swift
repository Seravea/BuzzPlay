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
    // #12 — feedback pendant la latence d'ouverture de la sheet d'abonnement Apple Music
    @State private var isSubscribing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Apple Music banner
            appleMusicBanner
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, BuzzSpacing.md)

            // Lancer le Blind Test — invite les players sur leur buzzer
            launchButton
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, BuzzSpacing.md)

            // #BT-search — barre de recherche permanente en haut (au lieu d'un CTA caché en
            // bas) : découvrable immédiatement, les catégories en dessous sont des raccourcis.
            searchBarRow
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, BuzzSpacing.lg)

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
        .animation(.spring(duration: 0.3, bounce: 0.05), value: blindTestVM.playlists.isEmpty)
        .animation(.spring(duration: 0.3, bounce: 0.05), value: blindTestVM.isFetching)
    }

    // MARK: Launch Button

    private var launchButton: some View {
        let invited = blindTestVM.hasInvitedPlayers
        return Button {
            blindTestVM.invitePlayers()  // #invite-auto — ré-invite manuelle (joueur en retard)
        } label: {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: invited ? "checkmark.circle.fill" : "person.wave.2.fill")
                    .textStyle(Typography.footnoteBold)
                Text(invited ? "Joueurs invités" : "Inviter les joueurs")
                    .font(.nohemi(.subheadline, weight: .bold))
                Spacer()
                Text(invited ? "Appuyer pour ré-inviter" : "Auto — ou appuyer ici")
                    .font(.nohemi(.caption2, weight: .regular))
                    .foregroundStyle(.white.opacity(invited ? 0.5 : 0.65))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .fill(invited
                          ? AnyShapeStyle(Color.white.opacity(0.10))
                          : AnyShapeStyle(LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                                                         startPoint: .leading, endPoint: .trailing)))
            )
            .shadow(color: invited ? .clear : Color.greenButtonLeading.opacity(0.35), radius: 10, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.buzzFade, value: invited)
    }

    // MARK: Apple Music Banner

    private var appleMusicBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: blindTestVM.canPlayCatalogContent ? "music.note" : "music.note")
                .textStyle(Typography.footnoteEM)
                .foregroundStyle(blindTestVM.canPlayCatalogContent ? Color.greenButtonLeading : Color.mustardYellow)

            if blindTestVM.canPlayCatalogContent {
                (Text("Titre entier · ").foregroundStyle(.white)
                 + Text("Apple Music").foregroundStyle(Color.textSecondary))
                    .font(.nohemi(.caption, weight: .bold))
            } else {
                (Text("Preview ").foregroundStyle(Color.textSecondary)
                 + Text("15s").foregroundStyle(.white).bold()
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

    // MARK: Inline Search Bar

    private var searchBarRow: some View {
        HStack(spacing: BuzzSpacing.sm) {
            // #BT-search — loupe tappable = vraie action "Chercher" (en plus de la touche
            // "Rechercher" du clavier via submitLabel). Plus besoin de deviner "retour".
            Button { doSearch() } label: {
                Image(systemName: "magnifyingglass")
                    .textStyle(Typography.footnoteMedium)
                    .foregroundStyle(searchText.isEmpty ? Color.textMuted : Color.mustardYellow)
            }
            .buttonStyle(.plain)
            .disabled(searchText.isEmpty)

            TextField("", text: $searchText,
                      prompt: Text("Rechercher une playlist…").foregroundStyle(Color.textDim))
                .font(.nohemi(.body))
                .foregroundStyle(.white)
                .focused($searchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit { doSearch() }

            if !searchText.isEmpty {
                Button { searchText = ""; searchFocused = true } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textDim)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 11)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.md)
                .strokeBorder(
                    searchFocused ? Color.mustardYellow.opacity(0.5) : .white.opacity(0.12),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: searchFocused)
    }

    // MARK: Categories

    private var categoriesSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BuzzSpacing.xxl) {
                categoryRow(label: "GÉNÉRATION", items: generations)
                categoryRow(label: "GENRE", items: genres)
            }
            .padding(.bottom, BuzzSpacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private func categoryRow(label: String, items: [CategoryItem]) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text(label)
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(Color.textMuted)
                .tracking(0.8)
                .padding(.horizontal, BuzzSpacing.xl)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        CategoryCard(item: item) { doSearch(query: item.query) }
                    }
                }
            }
            // #BT-search/#13 — insets propres via contentMargins (au lieu de padder le
            // HStack, qui rognait la 1re card) + scroll indicators masqués.
            .contentMargins(.horizontal, BuzzSpacing.xl, for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    }

    // MARK: Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                let n = blindTestVM.playlists.count
                Text("\(n) PLAYLIST\(n > 1 ? "S" : "") TROUVÉE\(n > 1 ? "S" : "")")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .tracking(0.8)

                Spacer()

                Button {
                    withAnimation { blindTestVM.playlists = [] }
                    searchText = ""
                } label: {
                    Image(systemName: "xmark")
                        .textStyle(Typography.captionEM)
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.md)

            ScrollView {
                LazyVStack(spacing: BuzzSpacing.sm) {
                    ForEach(blindTestVM.playlists) { playlist in
                        BlindTestPlaylistRow(playlist: playlist) {
                            Task { await blindTestVM.selectPlaylist(playlist) }
                        }
                    }
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)
            }
        }
    }

    // MARK: Loading

    private var loadingView: some View {
        VStack(spacing: BuzzSpacing.md) {
            ProgressView().scaleEffect(1.2).tint(.white)
            Text("Recherche en cours…")
                .font(.nohemi(.subheadline, weight: .regular))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Helpers

    private func doSearch(query: String? = nil) {
        let q = query ?? searchText
        guard !q.isEmpty else { return }
        searchFocused = false
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
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.md))

                    Image(systemName: item.icon)
                        .textStyle(Typography.screenTitle)
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

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestSearchScreen(
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()),
            onSubscribeTap: {}
        )
    }
}
