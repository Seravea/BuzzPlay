//
//  Colors.swift
//  BuzzPlay
//

import Foundation
import SwiftUI

// MARK: - Color tokens
extension Color {
    // Brand foundations
    static let darkestPurple    = Color(_hex: "2A0944")
    static let darkPurple       = Color(_hex: "3B185F")
    static let darkPink         = Color(_hex: "A12568")
    static let mustardYellow    = Color(_hex: "FEC260")
    static let backgroundColor  = Color(_hex: "FCFBFD")
    static let sheetBg          = Color(_hex: "1A0535")
    static let deepDark         = Color(_hex: "0F172A")

    // CTA green
    static let greenButtonLeading  = Color(_hex: "00C950")
    static let greenButtonTrailing = Color(_hex: "00BC7D")

    // Destructive
    static let redLeading  = Color(_hex: "FB2C36")
    static let redTrailing = Color(_hex: "F6339A")
    static let redSoft     = Color(_hex: "FF6B70")
    static let errorLight  = Color(_hex: "EF4444")
    static let scarlet     = Color(_hex: "DC2626")
    static let crimson     = Color(_hex: "FF3E3E")

    // Positive
    static let greenLeading  = Color(_hex: "00C950")
    static let greenTrailing = Color(_hex: "009966")
    static let greenGlow     = Color(_hex: "7DFFA0")
    static let emerald       = Color(_hex: "10B981")
    static let teal          = Color(_hex: "059669")

    // Neutral – purple family
    static let purpleLeading  = Color(_hex: "AD46FF")
    static let purpleTrailing = Color(_hex: "F6339A")
    static let buzzIndigo     = Color(_hex: "7C3AED")
    static let softIndigo     = Color(_hex: "6366F1")

    // Pinks & reds
    static let buzzHotPink   = Color(_hex: "FF2D78")
    static let vibrantPink   = Color(_hex: "EC4899")
    static let fuchsia       = Color(_hex: "F43F5E")
    static let violet        = Color(_hex: "C026D3")

    // Secondary – yellow/orange family
    static let yellowLeading = Color(_hex: "F0B100")
    static let yellowTrailing = Color(_hex: "FF6900")
    static let amberWarm     = Color(_hex: "F59E0B")
    static let burnOrange    = Color(_hex: "EA580C")
    static let tangerine     = Color(_hex: "F97316")
    static let coral         = Color(_hex: "FF6B35")
    static let peach         = Color(_hex: "FF8C42")

    // Blue family
    static let blueLeading   = Color(_hex: "2B7FFF")
    static let blueTrailing  = Color(_hex: "00B8DB")
    static let royalBlue     = Color(_hex: "2563EB")
    static let skyBlue       = Color(_hex: "0EA5E9")
    static let oceanBlue     = Color(_hex: "0369A1")

    // Semantic text — dark mode permanent (fond violet foncé)
    static var textPrimary:   Color { .white }
    static var textSecondary: Color { .white.opacity(0.55) }
    static var textTertiary:  Color { .white.opacity(0.45) }
    static var textMuted:     Color { .white.opacity(0.40) }
    static var textDim:       Color { .white.opacity(0.35) }
    static var textFaint:     Color { .white.opacity(0.25) }
    static var textSoft:      Color { .white.opacity(0.70) }
}

// MARK: - LinearGradient tokens
extension LinearGradient {
    private static func h(_ leading: Color, _ trailing: Color) -> LinearGradient {
        LinearGradient(colors: [leading, trailing], startPoint: .leading, endPoint: .trailing)
    }

    // App gradients
    static let buzzSuccess  = h(.greenButtonLeading, .greenButtonTrailing)
    static let buzzDanger   = h(.redLeading, .redTrailing)
    static let buzzPrimary  = h(.purpleLeading, .purpleTrailing)
    static let buzzAmber    = h(.yellowLeading, .yellowTrailing)
    static let buzzMaster   = h(.blueLeading, .blueTrailing)

    // Player color gradients (GameColor)
    static let gradientRedPlayer    = h(.yellowTrailing, .buzzHotPink)
    static let gradientGreenPlayer  = h(.buzzHotPink, .purpleLeading)
    static let gradientBluePlayer   = h(.blueLeading, .blueTrailing)
    static let gradientYellowPlayer = h(.yellowLeading, .yellowTrailing)
    static let gradientPurplePlayer = h(.purpleLeading, .purpleTrailing)
}
