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
