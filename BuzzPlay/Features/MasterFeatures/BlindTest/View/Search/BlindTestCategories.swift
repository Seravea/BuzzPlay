//
//  BlindTestCategories.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Category data

struct CategoryItem: Identifiable {
    let id = UUID()
    let label: String
    let query: String
    let icon: String
    let colors: [Color]
}

let generations: [CategoryItem] = [
    .init(label: "70s", query: "années 70",   icon: "waveform.circle.fill",  colors: [Color.coral, Color.crimson]),
    .init(label: "80s", query: "années 80",   icon: "radio.fill",            colors: [Color.violet, Color.buzzIndigo]),
    .init(label: "90s", query: "années 90",   icon: "opticaldisc",           colors: [Color.royalBlue, Color.skyBlue]),
    .init(label: "00s", query: "années 2000", icon: "music.note.list",       colors: [Color.burnOrange, Color.amberWarm]),
    .init(label: "10s", query: "années 2010", icon: "headphones",            colors: [Color.oceanBlue, Color.deepDark]),
    .init(label: "20s", query: "années 2020", icon: "dot.radiowaves.left.and.right", colors: [Color.teal, Color.emerald]),
]

let genres: [CategoryItem] = [
    .init(label: "Pop",        query: "pop hits",           icon: "star.fill",   colors: [Color.vibrantPink, Color.fuchsia]),
    .init(label: "Rock",       query: "rock",               icon: "bolt.fill",   colors: [Color.scarlet, Color.burnOrange]),
    .init(label: "Hip-Hop",    query: "hip hop",            icon: "mic.fill",    colors: [Color.buzzIndigo, Color.softIndigo]),
    .init(label: "Électro",    query: "electro dance",      icon: "waveform",    colors: [Color.skyBlue, Color.softIndigo]),
    .init(label: "R&B · Soul", query: "r&b soul",           icon: "heart.fill",  colors: [Color.amberWarm, Color.errorLight]),
    .init(label: "Variété FR", query: "variété française",  icon: "music.note",  colors: [Color.royalBlue, Color.buzzIndigo]),
    .init(label: "K-Pop",      query: "k-pop",              icon: "crown.fill",  colors: [Color.vibrantPink, Color.buzzIndigo]),
    .init(label: "Latino",     query: "latino hits",        icon: "flame.fill",  colors: [Color.tangerine, Color.errorLight]),
]
