//
//  SunView.swift
//  BuzzPlay
//
//  Soleil du « système solaire » Blind Test = la cover du morceau, qui « respire »
//  (pulse) tant que la musique joue. Extrait de SolarSystemStageView.
//

import SwiftUI

struct SunView: View {
    let song: BlindTestSong?
    let isPlaying: Bool
    let diameter: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var animating: Bool { isPlaying && !reduceMotion }

    var body: some View {
        // Pulse piloté par une horloge déterministe (pause-aware) → jamais figé après une pause/reprise.
        TimelineView(.animation(paused: !animating)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let breath = animating ? 1 + 0.04 * sin(t * 2 * .pi / 2.0) : 1   // respiration ~2 s

            // Plus d'ondes concentriques (« trop ») : juste la respiration douce + un léger glow qui pulse.
            cover
                .scaleEffect(breath)
                .shadow(color: Color.mustardYellow.opacity(animating ? 0.25 + 0.20 * (0.5 + 0.5 * sin(t * 2 * .pi / 2.0)) : 0),
                        radius: 26)
        }
    }

    private var cover: some View {
        AsyncImage(url: song?.postertURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle()
                .fill(LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Image(systemName: "music.note").font(.largeTitle).foregroundStyle(.white.opacity(0.8)))
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.85), lineWidth: 3))
    }
}
