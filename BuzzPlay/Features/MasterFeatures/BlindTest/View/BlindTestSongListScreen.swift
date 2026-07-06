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
                        Text("Composer la file")
                            .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                            .foregroundStyle(.white)
                        Text(blindTestVM.isQueueEmpty
                             ? "Sélectionne plusieurs titres à enchaîner"
                             : "\(blindTestVM.queueCount) en file · \(blindTestVM.roundsDone) joués")
                            .font(.nohemi(.subheadline, weight: .regular))
                            .foregroundStyle(blindTestVM.isQueueEmpty ? Color.textSecondary : Color.mustardYellow)
                    }

                    Spacer()

                    // ✓ interpolé DANS le Text → posé sur la ligne de base, aligné aux chiffres.
                    Text("\(blindTestVM.roundsDone)/\(blindTestVM.roundsTotal) \(Image(systemName: BuzzIcon.checkSimple))")
                        .font(.nohemi(.caption, weight: .semiBold))
                        .foregroundStyle(.white)
                        .pillStyle(fill: .white.opacity(0.1), stroke: nil, compact: true, trailingIcon: true)
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
            .padding(.top, BuzzSpacing.lg)     // #header-air — ne pas coller à la nav bar
            .padding(.bottom, 14)

            // Liste des titres
            ScrollView {
                LazyVStack(spacing: BuzzSpacing.sm) {
                    ForEach(Array(blindTestVM.allSongs.enumerated()), id: \.element.id) { index, song in
                        BlindTestSongRow(
                            number: index + 1,
                            song: song,
                            isPlayed: blindTestVM.playedSongs.contains(song),
                            queuePosition: blindTestVM.queuePosition(of: song)
                        ) {
                            withAnimation { blindTestVM.toggleInQueue(song) }
                        }
                    }
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)
            }

            // Bouton Démarrer — visible dès qu'au moins un titre est dans la file
            if !blindTestVM.isQueueEmpty {
                let notInvited = !blindTestVM.hasInvitedPlayers
                // #gate-launch — invité mais pas TOUS prêts sur le buzzer : on bloque le lancement
                // (sinon un joueur rate la manche). « Réinviter » relance un retardataire ; « Retirer » débloque.
                let notReady = !notInvited && !blindTestVM.gameVM.allPlayersReady
                let blocked = notInvited || notReady
                let count = blindTestVM.queueCount
                Button {
                    blindTestVM.startQueue()
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
                             : "Démarrer · \(count) \(count > 1 ? "titres" : "titre")")
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
        .animation(.spring(duration: 0.3), value: blindTestVM.isQueueEmpty)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestSongListScreen(blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel())) {}
    }
}
