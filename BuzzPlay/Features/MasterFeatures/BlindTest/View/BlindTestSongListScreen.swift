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
            VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                HStack(spacing: BuzzSpacing.md) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .textStyle(Typography.label)
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Choisir un titre")
                            .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                            .foregroundStyle(.white)
                        Text("\(blindTestVM.allSongs.count) titres · \(blindTestVM.roundsDone) joués")
                            .font(.nohemi(.subheadline, weight: .regular))
                            .foregroundStyle(Color.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(blindTestVM.roundsDone)/\(blindTestVM.roundsTotal)")
                        Image(systemName: BuzzIcon.checkSimple)
                    }
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
                            Double(blindTestVM.roundsDone) / Double(blindTestVM.roundsTotal)
                        Capsule()
                            .fill(LinearGradient(colors: [.greenButtonLeading, .greenButtonTrailing],
                                                  startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 3)
                            .animation(.spring(), value: blindTestVM.roundsDone)
                    }
                }
                .frame(height: 3)
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, 14)

            // Liste des titres
            ScrollView {
                LazyVStack(spacing: BuzzSpacing.sm) {
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
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)
            }

            // Bouton Lancer — visible dès qu'un titre est sélectionné
            if blindTestVM.selectedMusic != nil {
                let notInvited = !blindTestVM.hasInvitedPlayers
                // #gate-launch — invité mais pas TOUS prêts sur le buzzer : on bloque le lancement
                // (sinon un joueur rate la manche). « Réinviter » relance un retardataire ; « Retirer » débloque.
                let notReady = !notInvited && !blindTestVM.gameVM.allPlayersReady
                let blocked = notInvited || notReady
                Button {
                    blindTestVM.startRound()
                } label: {
                    HStack(spacing: BuzzSpacing.sm) {
                        if blindTestVM.isFetching {
                            ProgressView().tint(.white).scaleEffect(0.9)
                        } else {
                            Image(systemName: notInvited ? "lock.fill" : notReady ? "hourglass" : "play.fill")
                                .textStyle(Typography.labelSM)
                        }
                        Text(blindTestVM.isFetching ? "Chargement…"
                             : notInvited ? "Invitez les joueurs d'abord"
                             : notReady ? "En attente des joueurs…"
                             : "Lancer la manche")
                            .font(.nohemi(.body, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BuzzSpacing.lg)
                    .background(
                        LinearGradient(colors: blocked ? [.white.opacity(0.08), .white.opacity(0.06)]
                                                          : [.purpleLeading, .purpleTrailing],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    )
                    .shadow(color: blocked ? .clear : Color.purpleLeading.opacity(0.35), radius: 8)
                    .opacity(blindTestVM.isFetching ? 0.7 : 1)
                }
                .buttonStyle(.plain)
                .disabled(blindTestVM.isFetching || blocked)
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, BuzzSpacing.xl)
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

                if isSelected && !isPlayed {
                    Image(systemName: "music.note")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.mustardYellow)
                } else if !isPlayed {
                    Image(systemName: "chevron.right")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.textFaint)
                }
            }
            .padding(BuzzSpacing.sm)
            .background(.white.opacity(isSelected ? 0.1 : 0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
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
