//
//  QuizBuzzSheet.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Buzz Bottom Sheet

struct QuizBuzzSheet: View {
    let player: Player
    let reactionTime: String
    /// #answer-window — top du buzz (epoch) ; nil = pas de barre.
    var buzzStartedAt: TimeInterval? = nil
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    /// Passé les 5s : on accentue la COULEUR du bouton « Refuser » (aucun mouvement).
    @State private var expired = false

    var body: some View {
        VStack(spacing: 14) {
            // Handle
            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

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

            // Team card
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .fill(player.teamColor.gradient)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(player.name.prefix(1)))
                            .font(.nohemi(.title3, weight: .bold)).titleTracking()
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("RÉACTION")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .tracking(0.5)
                    Text(reactionTime)
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(Color.mustardYellow)
                        .monospacedDigit()   // largeur de chiffre fixe → pas de tremblement
                        // pas de contentTransition/animation : 0 mouvement de roulement
                }
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, 6)
                .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: BuzzRadius.xxs)
                    .fill(player.teamColor.gradient)
                    .frame(width: 4)
                    .padding(.leading, 0)
                    .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.lg2))
            }

            // Validation buttons — différenciés par taille
            HStack(spacing: BuzzSpacing.sm) {
                validationButton(points: 10)
                validationButton(points: 20)
                validationButton(points: 30, highlighted: true)
            }

            // Reject button
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
