//
//  Theme.swift
//  BuzzPlay
//
//  ViewModifiers composites réutilisables.
//  Utiliser .glassCard(), .glassPill(), .primaryButtonStyle() etc. plutôt que les duplications inline.
//

import SwiftUI

// MARK: - Glass card (fond semi-transparent + bordure fine)
struct GlassCardModifier: ViewModifier {
    var radius: CGFloat
    var fill: CGFloat    // opacité du fond
    var border: CGFloat  // opacité de la bordure

    func body(content: Content) -> some View {
        content
            .background(.white.opacity(fill), in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(.white.opacity(border), lineWidth: 1))
    }
}

extension View {
    /// Card standard : fond blanc 6% + bordure 8% — usage général
    func glassCard(radius: CGFloat = BuzzRadius.lg) -> some View {
        modifier(GlassCardModifier(radius: radius, fill: 0.06, border: 0.08))
    }

    /// Card accentuée : fond blanc 8% + bordure 10% — éléments actifs
    func glassCardMedium(radius: CGFloat = BuzzRadius.xl) -> some View {
        modifier(GlassCardModifier(radius: radius, fill: 0.08, border: 0.10))
    }
}

// MARK: - Glass pill (Capsule)
struct GlassPillModifier: ViewModifier {
    var fill: CGFloat
    var border: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.white.opacity(fill), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(border), lineWidth: 1))
    }
}

extension View {
    /// Pill standard : fond 6% + bordure 10%
    func glassPill() -> some View {
        modifier(GlassPillModifier(fill: 0.06, border: 0.10))
    }

}

// MARK: - Nav bar Master (dark, opaque)
// #8 — sur iOS < 26, la nav bar repassait en light au scroll (fond clair + titre/boutons
// noirs illisibles sur le dégradé sombre). On force un fond opaque sombre + colorScheme dark.
// Inoffensif sur iOS 26+. À appliquer sur tous les écrans Master à nav bar système.
struct MasterDarkNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.darkestPurple, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func masterDarkNavBar() -> some View {
        modifier(MasterDarkNavBarModifier())
    }
}
