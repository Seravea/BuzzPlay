//
//  BlindTestSongListScreen.swift
//  BuzzPlay
//

import SwiftUI
import MusicKit

struct BlindTestSongListScreen: View {
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

                    Text("\(blindTestVM.playedSongs.count)/\(blindTestVM.roundsTotal) ✓")
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
                        let progress = blindTestVM.roundsTotal == 0 ? 0.0 :
                            Double(blindTestVM.playedSongs.count) / Double(blindTestVM.roundsTotal)
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

struct BlindTestSongRow: View {
    let number: Int
    let song: BlindTestSong
    let isPlayed: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Artwork avec badge played en overlay
                ZStack {
                    AsyncImage(url: song.postertURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        badgeColor
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    if isPlayed {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.black.opacity(0.55))
                            .frame(width: 56, height: 56)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
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
            .padding(8)
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

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestSongListScreen(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel())) {}
    }
}
