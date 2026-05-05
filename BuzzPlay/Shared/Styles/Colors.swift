//
//  Colors.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import SwiftUI


extension Color {
    // Brand foundations
    static let darkestPurple = Color(hex: "2A0944")
    static let darkPurple = Color(hex: "3B185F")
    static let darkPink = Color(hex: "A12568")
    static let mustardYellow = Color(hex: "FEC260")
    static let backgroundColor = Color(hex: "FCFBFD")
    static let sheetBg = Color(hex: "1A0535")

    // CTA green (StartingButtonView)
    static let greenButtonLeading = Color(hex: "00C950")
    static let greenButtonTrailing = Color(hex: "00BC7D")

    // Destructive
    static var redLeading: Color = Color(hex: "FB2C36")
    static var redTrailing: Color = Color(hex: "F6339A")
    static var redSoft: Color = Color(hex: "FF6B70")

    // Positive
    static var greenLeading: Color = Color(hex: "00C950")
    static var greenTrailing: Color = Color(hex: "009966")
    static var greenGlow: Color = Color(hex: "7DFFA0")

    // Neutral (purple-pink)
    static var purpleLeading: Color = Color(hex: "AD46FF")
    static var purpleTrailing: Color = Color(hex: "F6339A")

    // Secondary (yellow-orange)
    static var yellowLeading: Color = Color(hex: "F0B100")
    static var yellowTrailing: Color = Color(hex: "FF6900")

    // Master role accent (bleu)
    static var blueLeading: Color = Color(hex: "2B7FFF")
    static var blueTrailing: Color = Color(hex: "00B8DB")
}
