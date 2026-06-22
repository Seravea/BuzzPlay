//
//  BuzzPill.swift
//  BuzzPlay
//
//  Norme UNIQUE pour les pills / badges / chips (centrage optique cohérent).
//  Référence : « Conventions UI — Pills & Cards ».
//
//  Principe : « centré » ≠ padding égal. L'œil juge la masse visuelle.
//   • Ratio padding horizontal:vertical ≈ 2:1 (sous 1.5:1 = étriqué, au-dessus de 2.5:1 = flotte).
//   • Texte seul → la Capsule centre correctement par défaut ; + .fixedSize() (pas de compression).
//   • Icône directionnelle (play, chevron, forward) → SF Symbol + retirer ~3pt côté icône.
//   • Icône + texte → INTERPOLER le SF Symbol dans le Text : Text("\(Image(systemName:)) …").
//     Le symbole devient un glyphe posé sur la ligne de base → aligné quelle que soit la
//     police (un HStack[Image, Text] aligne sur le centre des boîtes → décalage avec Nohemi).
//   • Chiffre dans un cercle → Nohemi est calée HAUT dans sa boîte → léger nudge bas (1 seul knob).
//
//  Toute nouvelle pill DOIT passer par `.pillStyle(...)` ; tout badge chiffré par `BuzzCountBadge`.
//

import SwiftUI

// MARK: - Constantes de padding (ratio 2:1)

enum BuzzPill {
    /// Pill standard : H:V = 16:8 (2:1).
    static let padH: CGFloat = BuzzSpacing.lg   // 16
    static let padV: CGFloat = BuzzSpacing.sm   // 8

    /// Variante compacte (badges de statut, compteurs) : 12:6 (2:1).
    static let padHCompact: CGFloat = BuzzSpacing.md  // 12
    static let padVCompact: CGFloat = 6

    /// Compensation d'une icône directionnelle : on retire ~3pt du côté de l'icône
    /// (la pointe d'un triangle/chevron crée un vide optique de ce côté).
    static let directionalInset: CGFloat = 3
}

// MARK: - Knob optique unique (chiffre dans un cercle)

extension Typography {
    /// Chiffre dans un cercle (BuzzCountBadge) : Nohemi est calée haut → on pousse le chiffre
    /// vers le bas de `fontSize × ce ratio`. Valeur validée à l'œil + calcul métrique (0.082–0.12).
    static let badgeDigitNudgeRatio: CGFloat = 0.10

    /// Pills : le texte Nohemi (pire avec un « / » descendant) paraît haut dans la capsule.
    /// Décalage vertical UNIQUE (pt, vers le bas) appliqué par .pillStyle à tout le contenu
    /// des pills → centrage optique cohérent partout. 0 = annule.
    static let pillContentNudge: CGFloat = 1
}

// MARK: - Modifier pill (capsule)

extension View {
    /// Applique la norme pill : ratio padding 2:1 + capsule + bordure + .fixedSize.
    /// `compact` = badge de statut/compteur (12:6) ; sinon standard (16:8).
    /// `iconInset` = pille texte + icône directionnelle à droite → retire ~3pt à droite.
    func pillStyle(fill: Color = .white.opacity(0.10),
                   stroke: Color? = .white.opacity(0.12),
                   compact: Bool = false,
                   trailingIcon: Bool = false) -> some View {
        let padH = compact ? BuzzPill.padHCompact : BuzzPill.padH
        let padV = compact ? BuzzPill.padVCompact : BuzzPill.padV
        return self
            // Correction optique Nohemi (calée haut) : pousse le contenu vers le bas SANS
            // bouger la capsule (offset ne change pas le frame de layout). Knob unique.
            .offset(y: Typography.pillContentNudge)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.leading, padH)
            .padding(.trailing, padH - (trailingIcon ? BuzzPill.directionalInset : 0))
            .padding(.vertical, padV)
            .background(fill, in: Capsule())
            .overlay { if let stroke { Capsule().strokeBorder(stroke, lineWidth: 1) } }
    }
}

// MARK: - Badge chiffré (cercle)

/// Chiffre/initiale centré dans un cercle (rang, position de file, compteur).
/// Centrage optique : police fixe + nudge bas piloté par `Typography.badgeDigitNudgeRatio`.
struct BuzzCountBadge: View {
    let text: String
    var diameter: CGFloat = 26
    var fontSize: CGFloat = 13
    var weight: NohemiWeight = .black
    var fill: AnyShapeStyle = AnyShapeStyle(Color.mustardYellow)
    var textColor: Color = .sheetBg

    init(_ text: String,
         diameter: CGFloat = 26,
         fontSize: CGFloat = 13,
         weight: NohemiWeight = .black,
         fill: AnyShapeStyle = AnyShapeStyle(Color.mustardYellow),
         textColor: Color = .sheetBg) {
        self.text = text
        self.diameter = diameter
        self.fontSize = fontSize
        self.weight = weight
        self.fill = fill
        self.textColor = textColor
    }

    var body: some View {
        Text(text)
            .font(.custom(weight.baseName, size: fontSize))
            .foregroundStyle(textColor)
            .offset(y: fontSize * Typography.badgeDigitNudgeRatio)   // Nohemi sied haut → nudge bas
            .frame(width: diameter, height: diameter)
            .background(fill, in: Circle())
    }
}

#Preview {
    VStack(spacing: BuzzSpacing.lg) {
        HStack(spacing: BuzzSpacing.md) {
            BuzzCountBadge("1")
            BuzzCountBadge("3", diameter: 34, fontSize: 15)
            BuzzCountBadge("12", fill: AnyShapeStyle(Color.white.opacity(0.12)), textColor: .white)
        }
        Text("EN COURS")
            .font(.nohemi(.caption, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(.white)
            .pillStyle(compact: true)
        Text("Passer \(Image(systemName: "forward.end.fill"))")
            .font(.nohemi(.caption, weight: .bold))
            .foregroundStyle(.white)
            .pillStyle(compact: true, trailingIcon: true)
    }
    .padding()
    .background(Color.sheetBg)
}
