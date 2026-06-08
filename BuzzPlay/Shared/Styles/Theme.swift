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

    /// Card légère : fond blanc 5% + bordure 8% — éléments secondaires
    func glassCardLight(radius: CGFloat = BuzzRadius.lg2) -> some View {
        modifier(GlassCardModifier(radius: radius, fill: 0.05, border: 0.08))
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

    /// Pill légère : fond 4% + bordure 8%
    func glassPillLight() -> some View {
        modifier(GlassPillModifier(fill: 0.04, border: 0.08))
    }
}

// MARK: - Section header
struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textStyle(Typography.sectionTitle)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
}

// MARK: - Overlay label (texte blanc sur fond sombre)
struct OverlayLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textStyle(Typography.labelSM)
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, BuzzSpacing.md)
            .padding(.vertical, BuzzSpacing.xs)
            .glassCard(radius: BuzzRadius.pill)
    }
}

extension View {
    func overlayLabelStyle() -> some View {
        modifier(OverlayLabelModifier())
    }
}
