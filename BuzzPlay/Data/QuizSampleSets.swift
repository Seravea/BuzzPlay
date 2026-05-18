//
//  QuizSampleSets.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Thèmes

enum QuizThemes {
    static let music = QuizTheme(
        title: "Musique",
        emoji: "🎵",
        color: .purple
    )

    static let cinema = QuizTheme(
        title: "Cinéma & Séries",
        emoji: "🎬",
        color: .orange
    )

    static let cultureG = QuizTheme(
        title: "Culture G",
        emoji: "🌍",
        color: .teal
    )

    static let all: [QuizTheme] = [music, cinema, cultureG]
}

// MARK: - Sets

enum QuizSamples {

    // MARK: Musique

    static let music2000s: QuizSet = QuizSet(
        title: "Tubes des années 2000",
        theme: QuizThemes.music,
        questions: [
            QuizQuestion(title: "Qui chante « …Baby One More Time » (1998) ?",
                         answers: ["Britney Spears"],
                         theme: "Musique", difficulty: 1, tone: nil,
                         indices: ["Chanteuse américaine", "Prénom : B*******"]),
            QuizQuestion(title: "Qui interprète « Wonderwall » ?",
                         answers: ["Oasis"],
                         theme: "Musique", difficulty: 1, tone: nil,
                         indices: ["Groupe britannique des années 90", "Frères Gallagher"]),
            QuizQuestion(title: "Quel duo français est derrière « Around the World » ?",
                         answers: ["Daft Punk"],
                         theme: "Musique", difficulty: 2, tone: nil,
                         indices: ["Casques de robots", "French House"]),
            QuizQuestion(title: "Qui a sorti « Lose Yourself » ?",
                         answers: ["Eminem"],
                         theme: "Musique", difficulty: 1, tone: nil,
                         indices: ["Rappeur de Detroit", "8 Mile"]),
            QuizQuestion(title: "Qui chante « Hips Don't Lie » ?",
                         answers: ["Shakira", "Wyclef Jean"],
                         theme: "Musique", difficulty: 2, tone: nil,
                         indices: ["Artiste colombienne", "Hanche qui ne ment pas…"]),
            QuizQuestion(title: "Quel groupe interprète « Bring Me to Life » (2003) ?",
                         answers: ["Evanescence"],
                         theme: "Musique", difficulty: 2, tone: nil,
                         indices: ["Rock gothique américain", "Chanteuse Amy L."]),
            QuizQuestion(title: "Qui chante « Umbrella » ?",
                         answers: ["Rihanna", "Jay-Z"],
                         theme: "Musique", difficulty: 1, tone: nil,
                         indices: ["Chanteuse de la Barbade", "Elle-ella-ella"]),
            QuizQuestion(title: "Quel DJ français a sorti « Love Don't Let Me Go » ?",
                         answers: ["David Guetta"],
                         theme: "Musique", difficulty: 2, tone: nil,
                         indices: ["DJ parisien", "One Love (album)"]),
            QuizQuestion(title: "Qui chante « Toxic » (2003) ?",
                         answers: ["Britney Spears"],
                         theme: "Musique", difficulty: 1, tone: nil,
                         indices: ["Même artiste que « Baby One More Time »", "Princesse de la pop"]),
            QuizQuestion(title: "Quel groupe est connu pour « Numb » (2003) ?",
                         answers: ["Linkin Park"],
                         theme: "Musique", difficulty: 2, tone: nil,
                         indices: ["Nu-metal américain", "Chester B. au chant"])
        ]
    )

    static let musicFrench: QuizSet = QuizSet(
        title: "Variété française cultes",
        theme: QuizThemes.music,
        questions: [
            QuizQuestion(title: "Qui chante « Alexandrie Alexandra » ?",
                         answers: ["Claude François"],
                         theme: "Musique", difficulty: 2, tone: nil),
            QuizQuestion(title: "Qui interprète « Belle » dans Notre-Dame de Paris ?",
                         answers: ["Garou", "Daniel Lavoie", "Patrick Fiori"],
                         theme: "Musique", difficulty: 3, tone: nil),
            QuizQuestion(title: "Qui chante « Les Champs-Élysées » ?",
                         answers: ["Joe Dassin"],
                         theme: "Musique", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quel artiste français a composé « Je l'aime à mourir » ?",
                         answers: ["Francis Cabrel"],
                         theme: "Musique", difficulty: 2, tone: nil),
            QuizQuestion(title: "Qui chante « Ne me quitte pas » ?",
                         answers: ["Jacques Brel"],
                         theme: "Musique", difficulty: 1, tone: nil),
            QuizQuestion(title: "Qui interprète « Lettre à France » ?",
                         answers: ["Michel Polnareff"],
                         theme: "Musique", difficulty: 3, tone: nil),
            QuizQuestion(title: "Quel groupe français chante « Aux Champs-Élysées » version rock ?",
                         answers: ["Téléphone"],
                         theme: "Musique", difficulty: 3, tone: nil),
            QuizQuestion(title: "Qui chante « Dernière danse » (2013) ?",
                         answers: ["Indila"],
                         theme: "Musique", difficulty: 1, tone: nil),
            QuizQuestion(title: "Qui interprète « Papaoutai » ?",
                         answers: ["Stromae"],
                         theme: "Musique", difficulty: 1, tone: nil),
            QuizQuestion(title: "Qui chante « La vie en rose » ?",
                         answers: ["Édith Piaf"],
                         theme: "Musique", difficulty: 1, tone: nil)
        ]
    )

    // MARK: Cinéma & Séries

    static let cinemaCult: QuizSet = QuizSet(
        title: "Répliques de films cultes",
        theme: QuizThemes.cinema,
        questions: [
            QuizQuestion(title: "« Je suis ton père » — dans quel film ?",
                         answers: ["Star Wars", "L'Empire contre-attaque"],
                         theme: "Cinéma", difficulty: 1, tone: nil),
            QuizQuestion(title: "« Houston, on a un problème » — quel film ?",
                         answers: ["Apollo 13"],
                         theme: "Cinéma", difficulty: 2, tone: nil),
            QuizQuestion(title: "« La vie, c'est comme une boîte de chocolats » — quel film ?",
                         answers: ["Forrest Gump"],
                         theme: "Cinéma", difficulty: 1, tone: nil),
            QuizQuestion(title: "« Mon précieux » — quel personnage prononce cette phrase ?",
                         answers: ["Gollum"],
                         theme: "Cinéma", difficulty: 1, tone: nil),
            QuizQuestion(title: "« T'as voulu voir Vesoul » — quel film français ?",
                         answers: ["Les Bronzés font du ski", "Les Bronzés"],
                         theme: "Cinéma", difficulty: 3, tone: nil),
            QuizQuestion(title: "« Casse-toi pauvre con » — dans quel film cette réplique est détournée ?",
                         answers: ["OSS 117"],
                         theme: "Cinéma", difficulty: 3, tone: nil),
            QuizQuestion(title: "« À demain ! À demain ! » — quel film des Inconnus ?",
                         answers: ["Les Trois Frères"],
                         theme: "Cinéma", difficulty: 2, tone: nil),
            QuizQuestion(title: "« Je reviendrai » (I'll be back) — quel acteur ?",
                         answers: ["Arnold Schwarzenegger"],
                         theme: "Cinéma", difficulty: 1, tone: nil),
            QuizQuestion(title: "« Ils sont fous ces Romains » — quelle saga ?",
                         answers: ["Astérix"],
                         theme: "Cinéma", difficulty: 1, tone: nil),
            QuizQuestion(title: "« Tu es un sorcier, Harry » — qui dit cette phrase ?",
                         answers: ["Hagrid", "Rubeus Hagrid"],
                         theme: "Cinéma", difficulty: 1, tone: nil)
        ]
    )

    static let seriesTV: QuizSet = QuizSet(
        title: "Séries TV à succès",
        theme: QuizThemes.cinema,
        questions: [
            QuizQuestion(title: "Dans quelle série suit-on Walter White, prof de chimie ?",
                         answers: ["Breaking Bad"],
                         theme: "Séries", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quelle série se déroule à Westeros ?",
                         answers: ["Game of Thrones", "Le Trône de fer"],
                         theme: "Séries", difficulty: 1, tone: nil),
            QuizQuestion(title: "Dans Friends, quel est le métier de Ross ?",
                         answers: ["Paléontologue"],
                         theme: "Séries", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quelle série espagnole met en scène un braquage de la Maison de la Monnaie ?",
                         answers: ["La Casa de Papel"],
                         theme: "Séries", difficulty: 1, tone: nil),
            QuizQuestion(title: "Dans Stranger Things, dans quelle ville fictive se passe l'action ?",
                         answers: ["Hawkins"],
                         theme: "Séries", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quel est le nom du dragon préféré de Daenerys ?",
                         answers: ["Drogon"],
                         theme: "Séries", difficulty: 2, tone: nil),
            QuizQuestion(title: "Dans The Office (US), qui joue Michael Scott ?",
                         answers: ["Steve Carell"],
                         theme: "Séries", difficulty: 2, tone: nil),
            QuizQuestion(title: "Dans Kaamelott, qui joue le roi Arthur ?",
                         answers: ["Alexandre Astier"],
                         theme: "Séries", difficulty: 1, tone: nil),
            QuizQuestion(title: "Dans Peaky Blinders, quel est le nom de famille de la bande ?",
                         answers: ["Shelby"],
                         theme: "Séries", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quelle série Netflix suit une joueuse d'échecs orpheline ?",
                         answers: ["Le Jeu de la dame", "The Queen's Gambit"],
                         theme: "Séries", difficulty: 2, tone: nil)
        ]
    )

    // MARK: Culture G

    static let cultureGeoHistoire: QuizSet = QuizSet(
        title: "Histoire & géographie",
        theme: QuizThemes.cultureG,
        questions: [
            QuizQuestion(title: "En quelle année la Révolution française a-t-elle débuté ?",
                         answers: ["1789"],
                         theme: "Histoire", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quelle est la capitale de l'Australie ?",
                         answers: ["Canberra"],
                         theme: "Géographie", difficulty: 2, tone: nil),
            QuizQuestion(title: "Qui était le premier homme à marcher sur la Lune ?",
                         answers: ["Neil Armstrong"],
                         theme: "Histoire", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quel fleuve traverse Paris ?",
                         answers: ["La Seine", "Seine"],
                         theme: "Géographie", difficulty: 1, tone: nil),
            QuizQuestion(title: "En quelle année le mur de Berlin est-il tombé ?",
                         answers: ["1989"],
                         theme: "Histoire", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quel est le plus grand désert du monde ?",
                         answers: ["L'Antarctique", "Antarctique"],
                         theme: "Géographie", difficulty: 3, tone: nil),
            QuizQuestion(title: "Quel empereur a construit la Grande Muraille de Chine ?",
                         answers: ["Qin Shi Huang", "Qin Shi Huangdi"],
                         theme: "Histoire", difficulty: 3, tone: nil),
            QuizQuestion(title: "Dans quel pays se trouve le Machu Picchu ?",
                         answers: ["Pérou", "Le Pérou"],
                         theme: "Géographie", difficulty: 1, tone: nil),
            QuizQuestion(title: "En quelle année a eu lieu la bataille de Waterloo ?",
                         answers: ["1815"],
                         theme: "Histoire", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quelle est la plus longue rivière du monde ?",
                         answers: ["Le Nil", "Nil"],
                         theme: "Géographie", difficulty: 2, tone: nil)
        ]
    )

    static let cultureSciences: QuizSet = QuizSet(
        title: "Sciences & nature",
        theme: QuizThemes.cultureG,
        questions: [
            QuizQuestion(title: "Quelle est la formule chimique de l'eau ?",
                         answers: ["H2O"],
                         theme: "Sciences", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quelle planète est la plus proche du Soleil ?",
                         answers: ["Mercure"],
                         theme: "Sciences", difficulty: 1, tone: nil),
            QuizQuestion(title: "Combien d'os compte le corps humain adulte ?",
                         answers: ["206"],
                         theme: "Sciences", difficulty: 2, tone: nil),
            QuizQuestion(title: "Quel est le métal liquide à température ambiante ?",
                         answers: ["Mercure"],
                         theme: "Sciences", difficulty: 2, tone: nil),
            QuizQuestion(title: "Qui a formulé la théorie de la relativité ?",
                         answers: ["Albert Einstein", "Einstein"],
                         theme: "Sciences", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quel est l'animal terrestre le plus rapide ?",
                         answers: ["Le guépard", "Guépard"],
                         theme: "Nature", difficulty: 1, tone: nil),
            QuizQuestion(title: "Combien de cœurs possède une pieuvre ?",
                         answers: ["3", "Trois"],
                         theme: "Nature", difficulty: 3, tone: nil),
            QuizQuestion(title: "Quel gaz les plantes absorbent-elles pour la photosynthèse ?",
                         answers: ["Le dioxyde de carbone", "CO2", "Dioxyde de carbone"],
                         theme: "Sciences", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quel est le plus grand océan du monde ?",
                         answers: ["L'océan Pacifique", "Pacifique"],
                         theme: "Nature", difficulty: 1, tone: nil),
            QuizQuestion(title: "Quelle est l'unité de mesure de la force électrique ?",
                         answers: ["L'ampère", "Ampère"],
                         theme: "Sciences", difficulty: 2, tone: nil)
        ]
    )

    // MARK: - All

    static let all: [QuizSet] = [
        music2000s, musicFrench,
        cinemaCult, seriesTV,
        cultureGeoHistoire, cultureSciences
    ]

    /// Tous les sets d'un thème donné.
    static func sets(for theme: QuizTheme) -> [QuizSet] {
        all.filter { $0.theme == theme }
    }
}
