//
//  SolarSystemStageView.swift
//  BuzzPlay
//
//  Écran de lecture Master Blind Test repensé en « système solaire » :
//  - le SOLEIL = la cover du morceau, qui « respire » (pulse) tant que la musique joue ;
//  - les PLANÈTES = les joueurs, en orbite autour du soleil (initiale + couleur d'équipe + score) ;
//  - au BUZZ : l'orbite se FIGE, la planète du buzzeur s'illumine (halo + avant-plan), les autres se
//    ternissent — le soleil reste TOUJOURS visible.
//
//  Animations :
//  - (A) score-pop : quand un joueur marque, sa planète rebondit + un « +N » s'envole ;
//  - (C) entrée en cascade des planètes (stagger) à l'apparition ;
//  - (F) dérive lente de l'orbite au repos (entre deux morceaux), figée seulement au buzz / Reduce Motion.
//
//  ⚠️ Le pulse n'est PAS beat-synchronisé (MusicKit n'expose pas le niveau audio) : respiration régulière.
//  ⚠️ Angle d'orbite = ACCUMULATEUR (delta clampé) → vitesse variable sans saut + pas de saut à la reprise.
//

import SwiftUI

struct SolarSystemStageView: View {
    let song: BlindTestSong?
    let isPlaying: Bool
    let players: [Player]
    let buzzedPlayer: Player?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Accumulateur d'angle d'orbite (classe = mutée dans le body du TimelineView sans déclencher
    /// d'invalidation SwiftUI ; le TimelineView pilote déjà les redraws).
    private final class OrbitClock { var angle = 0.0; var last: Double? = nil }
    @State private var clock = OrbitClock()

    private let fullSpeed: Double = 12     // °/s quand ça joue
    private let driftSpeed: Double = 3     // °/s au repos (F)

    /// Orbite totalement figée au buzz ou en Reduce Motion ; sinon elle tourne (vite si ça joue, lent au repos).
    private var frozen: Bool { buzzedPlayer != nil || reduceMotion }
    private var speed: Double { isPlaying ? fullSpeed : driftSpeed }

    var body: some View {
        GeometryReader { geo in
            // Tailles ADAPTATIVES iPhone/iPad : proportionnelles mais clampées.
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let planetSize = min(max(side * 0.12, 42), 72)
            let sunDiameter = min(max(side * 0.36, 116), 230)
            let maxR = side / 2 - planetSize * 0.8
            let orbitInner = min(sunDiameter / 2 + planetSize * 0.7 + side * 0.03, maxR)
            let orbitOuter = max(orbitInner, min(maxR, orbitInner + planetSize * 1.25))
            let n = max(players.count, 1)

            ZStack(alignment: .bottom) {
                orbitRing(radius: orbitInner, opacity: 0.09).position(center)
                orbitRing(radius: orbitOuter, opacity: 0.06).position(center)

                SunView(song: song, isPlaying: isPlaying, diameter: sunDiameter)
                    .position(center)

                // Planètes = joueurs, orbite figeable (accumulateur d'angle)
                TimelineView(.animation(paused: frozen)) { context in
                    let _ = advanceClock(to: context.date.timeIntervalSinceReferenceDate)
                    ZStack {
                        ForEach(Array(players.enumerated()), id: \.element.id) { idx, player in
                            let isBuzzer = buzzedPlayer?.id == player.id
                            let dimmed = buzzedPlayer != nil && !isBuzzer
                            PlanetView(player: player, size: planetSize, index: idx,
                                       highlighted: isBuzzer, dimmed: dimmed)
                                .position(planetPosition(index: idx, n: n, center: center,
                                                         inner: orbitInner, outer: orbitOuter))
                                .zIndex(isBuzzer ? 10 : 0)
                                .animation(.spring(duration: 0.35, bounce: 0.45), value: buzzedPlayer?.id)
                        }
                    }
                }
                .zIndex(8)
            }
        }
    }

    /// Avance l'accumulateur d'angle d'orbite (delta clampé → pas de saut à la reprise post-buzz).
    private func advanceClock(to t: Double) {
        if let last = clock.last { clock.angle += min(t - last, 1.0 / 30) * speed }
        clock.last = t
    }

    /// Position d'une planète sur son orbite (rayon alterné pour la profondeur).
    private func planetPosition(index: Int, n: Int, center: CGPoint, inner: CGFloat, outer: CGFloat) -> CGPoint {
        let base = clock.angle.truncatingRemainder(dividingBy: 360)
        let r = index.isMultiple(of: 2) ? inner : outer
        let angle = (base + Double(index) / Double(n) * 360) * .pi / 180
        return CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                       y: center.y + CGFloat(sin(angle)) * r)
    }

    private func orbitRing(radius: CGFloat, opacity: Double) -> some View {
        Circle()
            .stroke(Color.white.opacity(opacity), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
            .frame(width: radius * 2, height: radius * 2)
    }
}

// MARK: - Soleil

private struct SunView: View {
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

// MARK: - Planète (joueur)

private struct PlanetView: View {
    let player: Player
    let size: CGFloat
    let index: Int
    let highlighted: Bool
    let dimmed: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var entered = false          // (C) entrée en cascade
    @State private var popScale: CGFloat = 1     // (A) rebond au score
    @State private var popDelta: Int? = nil      // (A) « +N » volant
    @State private var floatUp = false
    @State private var popTask: Task<Void, Never>?

    private var highlightScale: CGFloat { highlighted ? 1.28 : (dimmed ? 0.9 : 1.0) }

    var body: some View {
        VStack(spacing: size * 0.10) {
            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: size, height: size)
                .overlay(
                    // Lettre dans le rond : taille proportionnelle + nudge bas (Nohemi calé haut).
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.custom("Nohemi-Black", size: size * 0.42))
                        .foregroundStyle(.white)
                        .nohemiBadgeNudge(fontSize: size * 0.42)
                )
                .overlay(Circle().strokeBorder(.white.opacity(highlighted ? 0.95 : 0.7), lineWidth: highlighted ? 3 : 2))
                .shadow(color: player.teamColor.color.opacity(highlighted ? 0.8 : 0), radius: highlighted ? 16 : 0)
                .overlay(alignment: .top) { scoreFloat }   // (A) « +N »

            Text("\(player.score) pts")
                .font(.nohemi(.caption2, weight: .semiBold))
                .foregroundStyle(.white.opacity(0.65))
                .monospacedDigit()
                .fixedSize()
        }
        // Tout le VStack grossit/rétrécit ensemble → les points suivent la planète.
        .scaleEffect((entered ? 1 : 0.3) * highlightScale * popScale)
        .opacity(entered ? (dimmed ? 0.32 : 1.0) : 0)
        .onAppear {
            if reduceMotion { entered = true }
            else { withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.07)) { entered = true } }
        }
        .onChange(of: player.score) { old, new in
            guard new > old else { return }
            triggerPop(delta: new - old)
        }
    }

    @ViewBuilder
    private var scoreFloat: some View {
        if let d = popDelta {
            Text("+\(d)")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.greenGlow)
                .monospacedDigit()
                .fixedSize()
                .offset(y: floatUp ? -size * 0.75 : -size * 0.1)
                .opacity(floatUp ? 0 : 1)
                .onAppear { floatUp = false; withAnimation(.easeOut(duration: 1.0)) { floatUp = true } }
                .onDisappear { floatUp = false }
        }
    }

    private func triggerPop(delta: Int) {
        popDelta = delta
        popTask?.cancel()
        popTask = Task { @MainActor in
            if !reduceMotion {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) { popScale = 1.2 }
                try? await Task.sleep(for: .seconds(0.22))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { popScale = 1.0 }
            }
            try? await Task.sleep(for: .seconds(0.85))
            popDelta = nil
        }
    }
}
