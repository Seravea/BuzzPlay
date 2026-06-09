//
//  ColorHex.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import SwiftUI


extension Color {
    // Internal use only — called by Colors.swift tokens. Do not call directly in views.
    init(_hex: String) {
        var hexString = _hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6 else { self = .gray; return }
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        self = Color(
            red:   Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8)  / 255.0,
            blue:  Double( rgbValue & 0x0000FF)         / 255.0
        )
    }

    // Deprecated — use a named token from Colors.swift instead (e.g. Color.buzzPurple)
    @available(*, deprecated, message: "Use a named Color token from Colors.swift instead of Color(hex:)")
    init(hex: String) {
        self.init(_hex: hex)
    }
}
