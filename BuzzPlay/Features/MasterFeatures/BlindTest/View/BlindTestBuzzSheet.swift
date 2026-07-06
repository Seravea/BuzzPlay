//
//  BlindTestBuzzSheet.swift
//  BuzzPlay
//

import SwiftUI

struct BlindTestBuzzSheet: View {
    let player: Player
    let reactionTime: String
    /// #answer-window — top du buzz (epoch) ; nil = pas de barre.
    var buzzStartedAt: TimeInterval? = nil
    /// Mode compact : masque la grosse carte joueur (la planète illuminée du système solaire dit déjà qui a buzzé).
    var compact: Bool = false
    /// #titre-buzz — morceau en cours = la réponse attendue. Affiché DANS la sheet car
    /// celle-ci masque la MusicCard « EN COURS » : le Master doit garder le titre/artiste
    /// sous les yeux pour juger la réponse au moment de valider.
    var song: BlindTestSong? = nil
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    /// Passé les 5s : on accentue la COULEUR du bouton « Refuser » (aucun mouvement).
    @State private var expired = false

    var body: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

            // #qui-buzz — NOM du joueur bien visible : en mode compact la carte joueur est masquée,
            // et la planète qui s'illumine ne suffit pas à lire qui a buzzé (retour test 2026-07-02).
            // La pastille reprend la couleur d'équipe → lien visuel avec sa planète du solar system.
            VStack(spacing: 4) {
                HStack(spacing: BuzzSpacing.sm) {
                    Circle()
                        .fill(player.teamColor.gradient)
                        .frame(width: 12, height: 12)
                    Text(player.name)
                        .font(.nohemi(.title3, weight: .bold)).titleTracking()
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                // #answer-window — « A BUZZÉ DEPUIS X s » : « depuis » dans le label, secondes colorées à part.
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(buzzStartedAt != nil ? "A BUZZÉ DEPUIS" : "A BUZZÉ")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(0.5)
                    if let started = buzzStartedAt {
                        BuzzCountdownRing(resetKey: started, font: .nohemi(.caption, weight: .bold))
                    }
                }
            }

            if !compact {
                BlindTestBuzzPlayerCard(player: player, reactionTime: reactionTime)
            }

            // #titre-buzz — réponse attendue (titre + artiste), pile au-dessus des boutons.
            if let song {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "music.note")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(Color.mustardYellow)
                        .frame(width: 34, height: 34)
                        .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(song.title)
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(song.releaseDate != nil ? "\(song.artist)  ·  \(song.releaseYearString)" : song.artist)
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: BuzzSpacing.sm)

                    Text("RÉPONSE")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(0.5)
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg2).strokeBorder(.white.opacity(0.1), lineWidth: 1))
            }

            HStack(spacing: BuzzSpacing.sm) {
                validationButton(points: 10)
                validationButton(points: 20)
                validationButton(points: 30, highlighted: true)
            }

            Button(action: onReject) {
                Label("Refuser la réponse", systemImage: BuzzIcon.xmark)
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(expired ? .white : Color.redSoft)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        expired
                        ? AnyShapeStyle(LinearGradient(colors: [Color.redLeading, Color.redTrailing],
                                                       startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color.redLeading.opacity(0.1)),
                        in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                    )
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.md).strokeBorder(Color.redLeading.opacity(expired ? 0 : 0.35), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.top, BuzzSpacing.md)
        .padding(.bottom, BuzzSpacing.lg)
        // #sheet-bottom — dans un NavigationStack, .ignoresSafeArea sur toute la sheet n'étend
        // pas le fond sous le home indicator (iPad/iPhone) → gap visible en bas. On étend le
        // FOND SEUL dans la safe area (le contenu reste au-dessus). Bas carré = collé à l'écran.
        .background {
            UnevenRoundedRectangle(topLeadingRadius: BuzzRadius.sheet, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: BuzzRadius.sheet)
                .fill(Color.sheetBg)
                .ignoresSafeArea(edges: .bottom)
        }
        .animation(.buzzFade, value: expired)   // crossfade couleur, aucun mouvement
        // #answer-window — décompte LOCAL (5s depuis l'apparition) : haptique + couleur du refus.
        .task(id: buzzStartedAt) {
            expired = false
            guard buzzStartedAt != nil else { return }
            try? await Task.sleep(for: .seconds(GameRhythm.answerWindow))
            guard !Task.isCancelled else { return }
            expired = true
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    /// #points-wording — libellé qualitatif de la validation (décision Romain 2026-07-02) :
    /// remplace « N réponses » (incompris des Masters) par « à quel point c'est bon ».
    private static func qualityLabel(_ points: Int) -> String {
        switch points {
        case 10: return "Pas bête"
        case 20: return "Malin"
        default: return "Génie"
        }
    }

    @ViewBuilder
    private func validationButton(points: Int, highlighted: Bool = false) -> some View {
        // #points-buttons — 3 boutons de MÊME taille, pleine largeur (comme « Refuser »).
        // Différenciation par la TEINTE de vert (opacité du FOND seul), le texte reste plein
        // → plus lisible que l'ancienne opacité sur tout le bouton. « +N points » explicite, centré.
        let shade: Double = points >= 30 ? 1.0 : (points >= 20 ? 0.80 : 0.60)
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onValidate(points)
        } label: {
            VStack(spacing: 2) {
                Text("+\(points) points")
                    .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(Self.qualityLabel(points))
                    .font(.nohemi(.caption2, weight: .semiBold))
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                               startPoint: .leading, endPoint: .trailing)
                    .opacity(shade),
                in: RoundedRectangle(cornerRadius: BuzzRadius.md)
            )
            .shadow(color: Color.greenButtonLeading.opacity(highlighted ? 0.4 : 0.15), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        BlindTestBuzzSheet(
            player: Player(name: "L'équipe", teamColor: .blueGame),
            reactionTime: "0.45s",
            onValidate: { _ in },
            onReject: {}
        )
    }
}
