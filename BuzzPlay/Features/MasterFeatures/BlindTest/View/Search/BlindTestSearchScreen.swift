//
//  BlindTestSearchScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

// MARK: - Main View

struct BlindTestSearchScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onSubscribeTap: () -> Void

    @FocusState private var searchFocused: Bool
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Apple Music banner
            AppleMusicBanner(blindTestVM: blindTestVM, onSubscribeTap: onSubscribeTap)
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.top, BuzzSpacing.lg)     // #header-air — ne pas coller à la nav bar
                .padding(.bottom, BuzzSpacing.md)

            // #invite-progress — avant l'invite : CTA de lancement ; une fois invité :
            // barre « X/Y prêts » + bouton « Réinviter » (actif si des joueurs manquent).
            if !blindTestVM.hasInvitedPlayers {
                launchButton
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.md)
            } else if blindTestVM.gameVM.totalPlayersCount > 0 {
                InviteProgressRow(ready: blindTestVM.gameVM.readyAndConnectedCount,
                                  total: blindTestVM.gameVM.totalPlayersCount,
                                  onReinvite: { blindTestVM.invitePlayers() })
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.md)
            }

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

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestSearchScreen(
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()),
            onSubscribeTap: {}
        )
    }
}
