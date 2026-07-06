//
//  HomeCardMetrics.swift
//  BuzzPlay
//

import CoreGraphics

// #R1 — métriques PARTAGÉES : les 2 cartes « Rejoindre » / « Animer » ont exactement
// la même géométrie (icône, paddings, espacements, flèche) ; seuls le fond, l'ombre et
// les opacités les distinguent (principal plein/dégradé vs secondaire discret).
// Valeurs à affiner à l'œil device si besoin.
enum HomeCardMetrics {
    // Marge intérieure & alignements PARTAGÉS (même padding = marges alignées, #R1).
    // La taille d'icône/titre, elle, diffère par carte pour garder « Rejoindre » plus
    // grand (hiérarchie voulue par Romain) sans casser l'alignement des marges.
    static let iconTextSpacing: CGFloat = 14
    static let trailingPointSize: CGFloat = 18
    static let padding: CGFloat = 18
    static let corner: CGFloat = 22
}
