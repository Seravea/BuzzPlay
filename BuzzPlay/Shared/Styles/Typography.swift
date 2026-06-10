//
//  Typography.swift
//  BuzzPlay
//
//  Tokens sémantiques — toujours utiliser .textStyle(Typography.xxx) sur du texte.
//  Les tailles SF Symbol (Image(systemName:)) restent sur .font(.system(size:)) — intentionnel.
//

import SwiftUI

// MARK: - Additional semantic tokens (extends TextExtensions.swift)
extension Typography {

    // MARK: Screen titles — grands titres de vue
    // #2 — titres gras routés vers la constante centrale Typography.titleTracking (réglage device).
    static let screenTitle      = Token(.title,        weight: .bold,     tracking: titleTracking)   // ~28pt bold
    static let screenTitleSoft  = Token(.title,        weight: .medium)                              // ~28pt medium

    // MARK: Section & card headers
    static let sectionTitle     = Token(.title2,       weight: .semiBold, tracking: titleTracking)   // ~22pt semiBold
    static let sectionTitleSoft = Token(.title2,       weight: .medium)                              // ~22pt medium
    static let cardTitle        = Token(.title3,       weight: .semiBold, tracking: titleTracking)   // ~20pt semiBold
    static let cardTitleBold    = Token(.title3,       weight: .bold,     tracking: titleTracking)   // ~20pt bold

    // MARK: Labels
    static let labelXL          = Token(.headline,     weight: .semiBold)                  // ~17pt semiBold
    static let label            = Token(.callout,      weight: .semiBold)                  // ~16pt semiBold
    static let labelBold        = Token(.callout,      weight: .bold)                      // ~16pt bold
    static let labelSM          = Token(.subheadline,  weight: .semiBold)                  // ~15pt semiBold
    static let labelSMBold      = Token(.subheadline,  weight: .bold)                      // ~15pt bold

    // MARK: Footnote variants
    static let footnoteEM       = Token(.footnote,     weight: .semiBold, tracking: 0.1)   // ~13pt semiBold
    static let footnoteBold     = Token(.footnote,     weight: .bold,     tracking: 0.1)   // ~13pt bold
    static let footnoteMedium   = Token(.footnote,     weight: .medium,   tracking: 0.1)   // ~13pt medium

    // MARK: Caption variants
    static let captionEM        = Token(.caption,      weight: .semiBold, tracking: 0.1)   // ~12pt semiBold
    static let captionBold      = Token(.caption,      weight: .bold,     tracking: 0.2)   // ~12pt bold

    // MARK: Caption2 variants
    static let caption2EM       = Token(.caption2,     weight: .semiBold, tracking: 0.3)   // ~11pt semiBold
    static let caption2Bold     = Token(.caption2,     weight: .bold,     tracking: 0.5)   // ~11pt bold
    static let micro            = Token(.caption2,     weight: .black,    tracking: 0.5)   // ~11pt black → rank badge
}
