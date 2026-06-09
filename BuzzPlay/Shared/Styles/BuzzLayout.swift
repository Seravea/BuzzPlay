//
//  BuzzLayout.swift
//  BuzzPlay
//
//  Tokens de layout, d'animation et d'icônes.
//  Toujours utiliser ces constantes plutôt que des valeurs en dur.
//

import SwiftUI

// MARK: - Spacing
enum BuzzSpacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20   // padding horizontal page standard
    static let xxl:  CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner radius
enum BuzzRadius {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm2:  CGFloat = 10   // éléments compacts
    static let sm:   CGFloat = 12   // tags, chips
    static let md:   CGFloat = 14   // boutons standard (le plus fréquent)
    static let lg:   CGFloat = 16   // cards
    static let lg2:  CGFloat = 18   // cards plus grandes
    static let xl:   CGFloat = 20   // grandes cards
    static let xxl:  CGFloat = 24   // very large cards
    static let sheet: CGFloat = 28  // sheets / overlays
    static let pill:  CGFloat = 999 // capsule / pill
}

// MARK: - Animation tokens
extension Animation {
    static let buzzSnappy = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let buzzDefault = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let buzzSmooth  = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let buzzBouncy  = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let buzzFade    = Animation.easeInOut(duration: 0.25)
    static let buzzEase    = Animation.easeInOut(duration: 0.3)
    static let buzzSlide   = Animation.easeOut(duration: 0.3)
}

// MARK: - SF Symbol names
enum BuzzIcon {
    static let check       = "checkmark.circle.fill"
    static let checkSimple = "checkmark"
    static let music       = "music.note"
    static let musicList   = "music.note.list"
    static let gift        = "gift.fill"
    static let bolt        = "bolt.fill"
    static let lock        = "lock.fill"
    static let sparkles    = "sparkles"
    static let waveform    = "waveform"
    static let chevronRight = "chevron.right"
    static let chevronLeft  = "chevron.left"
    static let xmark       = "xmark"
    static let magnifier   = "magnifyingglass"
    static let hint        = "lightbulb.fill"
    static let warning     = "exclamationmark.triangle.fill"
    static let play        = "play.fill"
    static let forward     = "forward.end.fill"
    static let crown       = "crown.fill"
    static let star        = "star.fill"
    static let timer       = "timer"
    static let person      = "person.wave.2.fill"
    static let notes       = "dollarsign.bank.building.fill"
    static let hourglass   = "hourglass"
    static let antenna     = "antenna.radiowaves.left.and.right"
    static let wifiOff     = "wifi.slash"
    static let flag        = "flag.checkered"
    static let pause       = "pause.circle.fill"
    static let refresh     = "arrow.counterclockwise.circle.fill"
    static let arrowRight  = "arrow.right"
    static let arrowUp     = "arrow.up"
    static let arrowDown   = "arrow.down"
    static let shield      = "shield.fill"
}
