//
//  BuzzCountdownRing.swift
//  BuzzPlay
//
//  #answer-window — affiche UNIQUEMENT les secondes « X s », posé juste après le texte de buzz
//  (« A BUZZÉ DEPUIS » côté Master, « … a buzzé depuis » côté Player) qui porte déjà le mot
//  « depuis ». Reçoit la MÊME police que ce texte voisin (param `font`) + alignement baseline au
//  call site → se lit comme une seule phrase, seules les secondes changent de couleur.
//  ⚠️ Ce n'est PAS un décompte couperet : le temps MONTE
//  et continue au-delà de 5s → repère INDICATIF / anti buzz-réflexe, jamais de refus automatique.
//  Le SIGNAL est la COULEUR, par paliers de `window` (5s) : vert < 5s → jaune 5–10s → rouge ≥ 10s.
//  En texte (et non plus en pastille) le compteur peut grimper sans jamais déborder visuellement.
//
//  ⚠️ Timing LOCAL : chaque device lance son propre compteur à l'apparition (les horloges des
//  téléphones ne sont pas synchronisées). `resetKey` (timestamp Master du buzz) ne sert qu'à
//  RÉINITIALISER le compteur à chaque nouveau buzz.
//
//  NB : le nom du fichier/struct dit encore « Ring » (anneau) par héritage — le composant ne
//  dessine plus d'anneau. À renommer en BuzzAnswerCounter si l'approche est validée device.
//

import SwiftUI

struct BuzzCountdownRing: View {
    /// Clé de reset (timestamp Master). Change = nouveau buzz → compteur réinitialisé.
    let resetKey: TimeInterval
    /// Unité de palier couleur : vert < window, jaune window–2×window, rouge ≥ 2×window.
    var window: TimeInterval = GameRhythm.answerWindow
    /// Police du libellé (override possible selon le texte voisin : caption Master / headline Player).
    var font: Font = .nohemi(.subheadline, weight: .semiBold)

    @State private var begin = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = max(0, context.date.timeIntervalSince(begin))
            let seconds = Int(elapsed)                     // monte : 0,1,2,… sans plafond
            let tint = color(forSeconds: elapsed)
            // #timer-jitter — Nohemi (police custom) n'a PAS de vrais chiffres à chasse fixe :
            // `.monospacedDigit()` seul ne suffit pas → le compteur bouge à chaque seconde.
            // On RÉSERVE la largeur de 2 chiffres via un gabarit caché « 00 » et on aligne le
            // chiffre à droite dedans → le « s » et la mise en page ne bougent plus (0→99s).
            HStack(spacing: 3) {
                // Le gabarit caché « 00 » impose un PLANCHER de 2 chiffres. Le ZStack prend la
                // taille du plus grand enfant → à 3 chiffres+ (attente très longue), le vrai
                // chiffre est plus large et le slot s'élargit tout seul, SANS troncature « … ».
                // Même police que le gabarit → suit aussi l'agrandissement Dynamic Type.
                ZStack(alignment: .trailing) {
                    Text(verbatim: "00").hidden()
                    Text(verbatim: "\(seconds)")
                }
                Text("s")
            }
            .font(font)
            .foregroundStyle(tint)
            .monospacedDigit()
            .lineLimit(1)
            // Pas de contentTransition/animation sur le chiffre : il se met à jour INSTANTANÉMENT,
            // sans « roulement » → aucun mouvement visuel. Seule la COULEUR s'anime (crossfade).
            .animation(.buzzFade, value: tint)
        }
        .onAppear { begin = Date() }
        .onChange(of: resetKey) { begin = Date() }
    }

    private func color(forSeconds elapsed: Double) -> Color {
        if elapsed < window     { return Color.greenGlow }      // 0–5s
        if elapsed < window * 2 { return Color.mustardYellow }  // 5–10s
        return Color.redLeading                                  // ≥ 10s
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 10) {
            Text("A BUZZÉ !").font(.nohemi(.caption, weight: .bold)).foregroundStyle(.white.opacity(0.5))
            BuzzCountdownRing(resetKey: 0, font: .nohemi(.caption, weight: .bold))
        }
        HStack(spacing: 10) {
            Text("Ju a buzzé").font(.nohemi(.headline, weight: .regular)).foregroundStyle(.white.opacity(0.6))
            BuzzCountdownRing(resetKey: 1)
        }
    }
    .padding(40)
    .background(Color.sheetBg)
}
