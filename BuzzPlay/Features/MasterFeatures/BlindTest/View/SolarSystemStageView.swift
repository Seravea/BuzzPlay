//
//  SolarSystemStageView.swift
//  BuzzPlay
//
//  Écran de lecture Master Blind Test repensé en « système solaire » :
//  - le SOLEIL = la cover du morceau, qui « respire » (pulse) tant que la musique joue ;
//  - les PLANÈTES = les joueurs, en orbite lente autour du soleil (initiale + couleur d'équipe + score) ;
//  - au BUZZ : l'orbite se FIGE, la planète du buzzeur s'illumine (halo + avant-plan), les autres se
//    ternissent — le soleil (infos musique) reste TOUJOURS visible.
//
//  ⚠️ Le pulse n'est PAS beat-synchronisé (MusicKit/ApplicationMusicPlayer n'expose pas le niveau
//  audio temps réel) : c'est une respiration régulière = repère « le son est actif ».
//

import SwiftUI

struct SolarSystemStageView: View {
    let song: BlindTestSong?
    let isPlaying: Bool
    let players: [Player]
    let buzzedPlayer: Player?

    /// Orbite animée seulement quand ça joue ET que personne n'a buzzé (sinon figée).
    private var rotating: Bool { isPlaying && buzzedPlayer == nil }
    private let degreesPerSecond: Double = 12

    var body: some View {
        GeometryReader { geo in
            // Tailles ADAPTATIVES iPhone/iPad : proportionnelles à l'espace mais clampées pour ne
            // jamais devenir minuscules (petit iPhone) ni énormes (grand iPad).
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let planetSize = min(max(side * 0.12, 42), 72)
            let sunDiameter = min(max(side * 0.36, 116), 230)
            // Rayons d'orbite calculés pour que les planètes dégagent toujours le soleil et restent
            // dans le cadre, quelle que soit la taille d'écran.
            let maxR = side / 2 - planetSize * 0.8
            let orbitInner = min(sunDiameter / 2 + planetSize * 0.7 + side * 0.03, maxR)
            let orbitOuter = max(orbitInner, min(maxR, orbitInner + planetSize * 1.25))

            ZStack(alignment: .bottom) {
                // Guides d'orbite (pointillés discrets)
                orbitRing(radius: orbitInner, opacity: 0.09).position(center)
                orbitRing(radius: orbitOuter, opacity: 0.06).position(center)

                // Soleil = cover + pulse
                SunView(song: song, isPlaying: isPlaying, diameter: sunDiameter)
                    .position(center)

                // Planètes = joueurs, orbite figeable
                TimelineView(.animation(paused: !rotating)) { context in
                    let base = context.date.timeIntervalSinceReferenceDate * degreesPerSecond
                    let n = max(players.count, 1)
                    ZStack {
                        ForEach(Array(players.enumerated()), id: \.element.id) { idx, player in
                            let isBuzzer = buzzedPlayer?.id == player.id
                            let dimmed = buzzedPlayer != nil && !isBuzzer
                            let r = idx.isMultiple(of: 2) ? orbitInner : orbitOuter
                            let angle = (base + Double(idx) / Double(n) * 360) * .pi / 180
                            PlanetView(player: player, size: planetSize, highlighted: isBuzzer, dimmed: dimmed)
                                .position(x: center.x + cos(angle) * r,
                                          y: center.y + sin(angle) * r)
                                .zIndex(isBuzzer ? 10 : 0)
                                .animation(.spring(duration: 0.35, bounce: 0.45), value: buzzedPlayer?.id)
                        }
                    }
                }

                // Infos musique (toujours lisibles, par-dessus l'orbite)
                songCaption
                    .padding(.bottom, side * 0.02)
                    .zIndex(20)
            }
        }
    }

    private func orbitRing(radius: CGFloat, opacity: Double) -> some View {
        Circle()
            .stroke(Color.white.opacity(opacity), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
            .frame(width: radius * 2, height: radius * 2)
    }

    private var songCaption: some View {
        VStack(spacing: 1) {
            Text(song?.title ?? "—")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(song?.artist ?? "—")
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 6)
        .background(Color.darkestPurple.opacity(0.75), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Soleil

private struct SunView: View {
    let song: BlindTestSong?
    let isPlaying: Bool
    let diameter: CGFloat

    @State private var pulse = false

    var body: some View {
        ZStack {
            // Ondes de pulse (seulement quand ça joue)
            if isPlaying {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(Color.mustardYellow.opacity(0.45))
                        .frame(width: diameter, height: diameter)
                        .scaleEffect(pulse ? 1.7 : 0.95)
                        .opacity(pulse ? 0 : 0.45)
                        .animation(.easeOut(duration: 2.4).repeatForever(autoreverses: false).delay(Double(i) * 1.2),
                                   value: pulse)
                }
            }

            // Cover
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
            .shadow(color: Color.mustardYellow.opacity(isPlaying ? 0.45 : 0), radius: 24)
            .scaleEffect(isPlaying && pulse ? 1.04 : 1.0)
            .animation(isPlaying ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: pulse)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Planète (joueur)

private struct PlanetView: View {
    let player: Player
    let size: CGFloat
    let highlighted: Bool
    let dimmed: Bool

    var body: some View {
        VStack(spacing: size * 0.10) {
            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: size, height: size)
                .overlay(
                    // Lettre dans le rond : taille proportionnelle au diamètre + nudge bas (le Nohemi
                    // est calé haut), comme la norme avatars de ScoreMasterView.
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.custom("Nohemi-Black", size: size * 0.42))
                        .foregroundStyle(.white)
                        .nohemiBadgeNudge(fontSize: size * 0.42)
                )
                .overlay(Circle().strokeBorder(.white.opacity(highlighted ? 0.95 : 0.7), lineWidth: highlighted ? 3 : 2))
                .shadow(color: player.teamColor.color.opacity(highlighted ? 0.8 : 0), radius: highlighted ? 16 : 0)

            Text("\(player.score) pts")
                .font(.nohemi(.caption2, weight: .semiBold))
                .foregroundStyle(.white.opacity(0.65))
                .monospacedDigit()
                .fixedSize()
        }
        // Tout le VStack grossit/rétrécit ensemble → les points SUIVENT la planète (plus cachés par le cercle).
        .scaleEffect(highlighted ? 1.28 : (dimmed ? 0.9 : 1.0))
        .opacity(dimmed ? 0.32 : 1.0)
    }
}
