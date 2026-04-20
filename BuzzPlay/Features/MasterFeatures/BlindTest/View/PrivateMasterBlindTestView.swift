//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Main Container

struct PrivateMasterBlindTestView: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel

    @State private var showValidationOverlay = false
    @State private var validationPoints = 0
    @State private var validationTeamName = ""

    private enum Screen: Equatable { case search, songList, playing }

    private var currentScreen: Screen {
        if blindTestVM.isGameActive { return .playing }
        if !blindTestVM.allSongs.isEmpty { return .songList }
        return .search
    }

    private let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            // Screen 1 — Recherche + playlists
            BlindTestSearchScreen(blindTestVM: blindTestVM)
                .offset(x: currentScreen == .search ? 0 : -screenWidth)
                .opacity(currentScreen == .search ? 1 : 0)

            // Screen 2 — Liste des titres
            BlindTestSongListScreen(blindTestVM: blindTestVM) {
                withAnimation {
                    blindTestVM.allSongs = []
                    blindTestVM.playlists = []
                    blindTestVM.selectedMusic = nil
                }
            }
            .offset(x: currentScreen == .songList ? 0 : (currentScreen == .search ? screenWidth : -screenWidth))
            .opacity(currentScreen == .songList ? 1 : 0)

            // Screen 3 — Manche active
            BlindTestActiveScreen(
                blindTestVM: blindTestVM,
                onValidate: handleValidate,
                onReject: { blindTestVM.rejectAnswer() }
            )
            .offset(x: currentScreen == .playing ? 0 : screenWidth)
            .opacity(currentScreen == .playing ? 1 : 0)

            // Overlay validation points
            if showValidationOverlay {
                QuizValidationOverlay(points: validationPoints, teamName: validationTeamName)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.45, bounce: 0.05), value: currentScreen)
        .onAppear {
            Task {
                await blindTestVM.appleMusicService.setupAppleMusic()
                await blindTestVM.updateCatalogPlaybackCapability()
            }
        }
        .alert("Information", isPresented: $blindTestVM.showSubscriptionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(blindTestVM.subscriptionAlertMessage)
        }
        .alert("Erreur", isPresented: Binding(
            get: { blindTestVM.fetchError != nil },
            set: { if !$0 { blindTestVM.fetchError = nil } }
        )) {
            Button("OK", role: .cancel) { blindTestVM.fetchError = nil }
        } message: {
            Text(blindTestVM.fetchError ?? "")
        }
    }

    private func handleValidate(points: Int) {
        validationPoints = points
        validationTeamName = blindTestVM.teamHasBuzz?.name ?? ""
        withAnimation(.spring(duration: 0.3, bounce: 0.2)) { showValidationOverlay = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            blindTestVM.validateAnswer(points: points)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.easeOut(duration: 0.3)) { showValidationOverlay = false }
        }
    }
}

// MARK: - Screen 1 : Recherche

private struct BlindTestSearchScreen: View {
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

// MARK: - Playlist Row

private struct BlindTestPlaylistRow: View {
    let playlist: BlindTestPlaylist
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "music.note.list")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.8))
                    )

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
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen 2 : Liste des titres

private struct BlindTestSongListScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Choisir un titre")
                            .font(.nohemi(.title2, weight: .extraBold))
                            .foregroundStyle(.white)
                        Text("\(blindTestVM.allSongs.count) titres · \(blindTestVM.playedSongs.count) joués")
                            .font(.nohemi(.subheadline, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    Text("\(blindTestVM.playedSongs.count)/\(blindTestVM.allSongs.count) ✓")
                        .font(.nohemi(.caption, weight: .semiBold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.1), in: Capsule())
                        .foregroundStyle(.white)
                }

                // Barre de progression
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.1)).frame(height: 3)
                        let progress = blindTestVM.allSongs.isEmpty ? 0.0 :
                            Double(blindTestVM.playedSongs.count) / Double(blindTestVM.allSongs.count)
                        Capsule()
                            .fill(LinearGradient(colors: [.greenButtonLeading, .greenButtonTrailing],
                                                  startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 3)
                            .animation(.spring(), value: blindTestVM.playedSongs.count)
                    }
                }
                .frame(height: 3)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Liste des titres
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(blindTestVM.allSongs.enumerated()), id: \.element.id) { index, song in
                        BlindTestSongRow(
                            number: index + 1,
                            song: song,
                            isPlayed: blindTestVM.playedSongs.contains(song),
                            isSelected: blindTestVM.selectedMusic == song
                        ) {
                            withAnimation { blindTestVM.selectedMusic = song }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }

            // Bouton Lancer
            if blindTestVM.selectedMusic != nil {
                Button {
                    blindTestVM.startRound()
                } label: {
                    HStack(spacing: 8) {
                        if blindTestVM.isFetching {
                            ProgressView().tint(.white).scaleEffect(0.9)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        Text(blindTestVM.isFetching ? "Chargement…" : "Lancer la manche")
                            .font(.nohemi(.body, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: Color.purpleLeading.opacity(0.35), radius: 8)
                    .opacity(blindTestVM.isFetching ? 0.7 : 1)
                }
                .buttonStyle(.plain)
                .disabled(blindTestVM.isFetching)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: blindTestVM.selectedMusic != nil)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Song Row

private struct BlindTestSongRow: View {
    let number: Int
    let song: BlindTestSong
    let isPlayed: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Badge numéro
                Text(isPlayed ? "✓" : "\(number)")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(song.artist)
                        .font(.nohemi(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(song.releaseYearString)
                    .font(.nohemi(.caption2, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))

                if isSelected && !isPlayed {
                    Image(systemName: "music.note")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mustardYellow)
                } else if !isPlayed {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.25))
                }
            }
            .padding(14)
            .background(.white.opacity(isSelected ? 0.1 : 0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .opacity(isPlayed ? 0.5 : 1)
        }
        .disabled(isPlayed)
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        if isPlayed  { return Color.greenButtonLeading.opacity(0.25) }
        if isSelected { return Color.mustardYellow.opacity(0.35) }
        return .white.opacity(0.1)
    }

    private var borderColor: Color {
        if isSelected { return Color.mustardYellow.opacity(0.4) }
        if isPlayed   { return Color.greenButtonLeading.opacity(0.25) }
        return .white.opacity(0.08)
    }
}

// MARK: - Screen 3 : Manche active

private struct BlindTestActiveScreen: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var buzzedTeam: Team? { blindTestVM.teamHasBuzz }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 14) {
                timerHero
                songCard
                scoresSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            // Assombrissement quand buzzé
            if buzzedTeam != nil {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {}
                    .transition(.opacity)
            }

            // Bottom sheet buzz
            if let team = buzzedTeam {
                BlindTestBuzzSheet(
                    team: team,
                    reactionTime: blindTestVM.formattedTime,
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.05), value: buzzedTeam != nil)
    }

    // Timer hero
    private var timerHero: some View {
        HStack {
            Text(blindTestVM.formattedTime)
                .font(.nohemi(.largeTitle, weight: .extraBold))
                .foregroundStyle(buzzedTeam != nil ? Color(hex: "#F6339A") : .mustardYellow)
                .tracking(3)
            Spacer()
            Text(buzzedTeam != nil ? "PAUSÉ" : (blindTestVM.isPlaying ? "EN COURS" : "TERMINÉ"))
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: 18))
    }

    // Carte chanson en cours
    private var songCard: some View {
        HStack(spacing: 14) {
            AsyncImage(url: blindTestVM.selectedMusic?.postertURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.5))
                    )
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text("EN COURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)
                Text(blindTestVM.selectedMusic?.title ?? "—")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
                Text(blindTestVM.selectedMusic?.artist ?? "—")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if blindTestVM.isPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .font(.title2)
                    .foregroundStyle(.mustardYellow)
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    // Classement en direct
    private var scoresSection: some View {
        let teams = blindTestVM.gameVM.teams.sorted { $0.score > $1.score }
        let maxScore = max(teams.map(\.score).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 8) {
            Text("CLASSEMENT EN DIRECT")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(0.8)
                .padding(.leading, 2)

            ForEach(teams) { team in
                QuizScoreRow(team: team, maxScore: maxScore)
            }

            if blindTestVM.isPlaying && buzzedTeam == nil {
                HStack(spacing: 10) {
                    RadarPulseView()
                    Text("En attente d'un buzz…")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Buzz Sheet BlindTest

struct BlindTestBuzzSheet: View {
    let team: Team
    let reactionTime: String
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 99)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

            Text("A BUZZÉ !")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.5)

            // Carte équipe
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(team.teamColor.gradient)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(team.name.prefix(1)))
                            .font(.nohemi(.title3, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                    Text(team.players.map(\.name).joined(separator: " · "))
                        .font(.nohemi(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("RÉACTION")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.5)
                    Text(reactionTime)
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(.mustardYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.1), lineWidth: 1))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(team.teamColor.gradient)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            // Boutons points
            HStack(spacing: 8) {
                pointButton(points: 10, scale: 0.88)
                pointButton(points: 20, scale: 0.94)
                pointButton(points: 30, scale: 1.0, highlighted: true)
            }

            // Refus
            Button(action: onReject) {
                Text("Refuser la réponse ✕")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6B70"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(hex: "#FB2C36").opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#FB2C36").opacity(0.35), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .background(Color(hex: "#1A0535"), in: RoundedRectangle(cornerRadius: 28))
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func pointButton(points: Int, scale: CGFloat, highlighted: Bool = false) -> some View {
        let responses = points / 10
        Button { onValidate(points) } label: {
            VStack(spacing: 2) {
                Text("+\(points)")
                    .font(.nohemi(.title3, weight: .extraBold))
                Text("\(responses) réponse\(responses > 1 ? "s" : "")")
                    .font(.nohemi(.caption2, weight: .semiBold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(colors: [.greenButtonLeading, .greenButtonTrailing],
                               startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .opacity(highlighted ? 1 : (scale < 0.9 ? 0.65 : 0.82))
            .shadow(color: highlighted ? Color.greenButtonLeading.opacity(0.35) : .clear, radius: 8)
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PrivateMasterBlindTestView(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundAppView())
}
