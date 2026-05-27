//
//  QuizSampleSets.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Thèmes musique

enum QuizThemes {

    // MARK: Décennies

    static let annees80 = QuizTheme(
        title: "Années 80",
        iconName: "radio",
        color: Color(hex: "#F0B100"),
        category: .era
    )
    static let annees90 = QuizTheme(
        title: "Années 90",
        iconName: "music.note.list",
        color: Color(hex: "#00C950"),
        category: .era
    )
    static let annees2000 = QuizTheme(
        title: "Années 2000",
        iconName: "opticaldisc",
        color: Color(hex: "#2B7FFF"),
        category: .era
    )
    static let annees2010 = QuizTheme(
        title: "Années 2010-2020",
        iconName: "iphone",
        color: Color(hex: "#AD46FF"),
        category: .era
    )

    // MARK: Genres

    static let popFR = QuizTheme(
        title: "Pop FR",
        iconName: "flag.fill",
        color: Color(hex: "#F6339A"),
        category: .genre
    )
    static let popIntl = QuizTheme(
        title: "Pop Internationale",
        iconName: "globe",
        color: Color(hex: "#FF6900"),
        category: .genre
    )
    static let rock = QuizTheme(
        title: "Rock",
        iconName: "guitars",
        color: Color(hex: "#FB2C36"),
        category: .genre
    )
    static let rapFR = QuizTheme(
        title: "Rap / Hip-Hop FR",
        iconName: "music.microphone",
        color: Color(hex: "#F0B100"),
        category: .genre
    )
    static let rapUS = QuizTheme(
        title: "Rap / Hip-Hop US",
        iconName: "music.microphone.fill",
        color: Color(hex: "#00B8DB"),
        category: .genre
    )
    static let electro = QuizTheme(
        title: "Électro / Dance",
        iconName: "headphones",
        color: Color(hex: "#00C950"),
        category: .genre
    )
    static let rnbSoul = QuizTheme(
        title: "R&B / Soul",
        iconName: "waveform.badge.star",
        color: Color(hex: "#FF8C42"),
        category: .genre
    )
    static let kpop = QuizTheme(
        title: "K-Pop",
        iconName: "sparkles",
        color: Color(hex: "#F6339A"),
        category: .genre
    )

    static let eras: [QuizTheme] = [annees80, annees90, annees2000, annees2010]
    static let genres: [QuizTheme] = [popFR, popIntl, rock, rapFR, rapUS, electro, rnbSoul, kpop]
    static let all: [QuizTheme] = eras + genres
}

// MARK: - Sets curatés

enum QuizSamples {

    // MARK: Années 80

    static let music80s = QuizSet(
        title: "Tubes des années 80",
        theme: QuizThemes.annees80,
        questions: [
            QuizQuestion(title: "Qui chante « Thriller » (1982) ?",
                         answers: ["Michael Jackson"],
                         theme: "Années 80", difficulty: .facile, tone: nil,
                         indices: ["Roi de la pop", "Clip avec des zombies"]),
            QuizQuestion(title: "Qui interprète « Sweet Child O' Mine » (1987) ?",
                         answers: ["Guns N' Roses"],
                         theme: "Années 80", difficulty: .facile, tone: nil,
                         indices: ["Groupe de hard rock américain", "Chanteur : Axl R."]),
            QuizQuestion(title: "Qui chante « Like a Virgin » (1984) ?",
                         answers: ["Madonna"],
                         theme: "Années 80", difficulty: .facile, tone: nil,
                         indices: ["Reine de la pop", "Américaine au prénom marial"]),
            QuizQuestion(title: "Quel duo chante « Wake Me Up Before You Go-Go » (1984) ?",
                         answers: ["Wham!"],
                         theme: "Années 80", difficulty: .moyen, tone: nil,
                         indices: ["Duo britannique", "George Michael avant sa carrière solo"]),
            QuizQuestion(title: "Qui chante « Purple Rain » (1984) ?",
                         answers: ["Prince"],
                         theme: "Années 80", difficulty: .facile, tone: nil,
                         indices: ["Artiste américain, symbole plutôt que nom", "Né à Minneapolis"]),
            QuizQuestion(title: "Qui interprète « Take On Me » (1985) ?",
                         answers: ["a-ha"],
                         theme: "Années 80", difficulty: .moyen, tone: nil,
                         indices: ["Groupe norvégien", "Clip en noir & blanc"]),
            QuizQuestion(title: "Qui chante « Girls Just Want to Have Fun » (1983) ?",
                         answers: ["Cyndi Lauper"],
                         theme: "Années 80", difficulty: .moyen, tone: nil,
                         indices: ["Chanteuse américaine aux cheveux colorés", "Prénom : C*****"]),
            QuizQuestion(title: "Quel groupe interprète « Don't You Want Me » (1981) ?",
                         answers: ["Human League"],
                         theme: "Années 80", difficulty: .difficile, tone: nil,
                         indices: ["Groupe de synthpop britannique", "Sheffield"]),
            QuizQuestion(title: "Qui chante « Relax » (1984) ?",
                         answers: ["Frankie Goes to Hollywood"],
                         theme: "Années 80", difficulty: .difficile, tone: nil,
                         indices: ["Groupe britannique controversé", "Censuré par la BBC"]),
            QuizQuestion(title: "Quel groupe interprète « Born to Run » (1975, icône des 80s) ?",
                         answers: ["Bruce Springsteen", "Bruce Springsteen and the E Street Band"],
                         theme: "Années 80", difficulty: .moyen, tone: nil,
                         indices: ["Le Boss", "New Jersey"])
        ]
    )

    // MARK: Années 90

    static let music90s = QuizSet(
        title: "Tubes des années 90",
        theme: QuizThemes.annees90,
        questions: [
            QuizQuestion(title: "Qui chante « Smells Like Teen Spirit » (1991) ?",
                         answers: ["Nirvana"],
                         theme: "Années 90", difficulty: .facile, tone: nil,
                         indices: ["Grunge américain", "Chanteur : Kurt C."]),
            QuizQuestion(title: "Quel groupe interprète « Wannabe » (1996) ?",
                         answers: ["Spice Girls"],
                         theme: "Années 90", difficulty: .facile, tone: nil,
                         indices: ["Girl band britannique", "Scary, Sporty, Baby, Ginger, Posh"]),
            QuizQuestion(title: "Qui chante « My Heart Will Go On » (1997) ?",
                         answers: ["Céline Dion"],
                         theme: "Années 90", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse québécoise", "Bande originale de Titanic"]),
            QuizQuestion(title: "Quel duo français est derrière « Da Funk » (1995) ?",
                         answers: ["Daft Punk"],
                         theme: "Années 90", difficulty: .moyen, tone: nil,
                         indices: ["French house", "Casques de robots"]),
            QuizQuestion(title: "Qui interprète « I Will Always Love You » en 1992 ?",
                         answers: ["Whitney Houston"],
                         theme: "Années 90", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse américaine", "Bande originale de The Bodyguard"]),
            QuizQuestion(title: "Quel groupe chante « Killing Me Softly » (1996) ?",
                         answers: ["Fugees", "Lauryn Hill"],
                         theme: "Années 90", difficulty: .moyen, tone: nil,
                         indices: ["Groupe hip-hop américain", "Wyclef Jean en est membre"]),
            QuizQuestion(title: "Quel groupe interprète « Creep » (1993) ?",
                         answers: ["Radiohead"],
                         theme: "Années 90", difficulty: .moyen, tone: nil,
                         indices: ["Rock alternatif britannique", "Thom Y. au chant"]),
            QuizQuestion(title: "Qui chante « Gangsta's Paradise » (1995) ?",
                         answers: ["Coolio"],
                         theme: "Années 90", difficulty: .moyen, tone: nil,
                         indices: ["Rappeur américain", "Bande originale de Dangerous Minds"]),
            QuizQuestion(title: "Quel groupe interprète « Everybody (Backstreet's Back) » (1997) ?",
                         answers: ["Backstreet Boys"],
                         theme: "Années 90", difficulty: .facile, tone: nil,
                         indices: ["Boys band américain", "5 membres"]),
            QuizQuestion(title: "Qui chante « Un Autre Monde » (1984, mais icône des années 90 FR) ?",
                         answers: ["Téléphone"],
                         theme: "Années 90", difficulty: .difficile, tone: nil,
                         indices: ["Groupe de rock français", "Jean-Louis Aubert au chant"])
        ]
    )

    // MARK: Années 2000

    static let music2000s = QuizSet(
        title: "Tubes des années 2000",
        theme: QuizThemes.annees2000,
        questions: [
            QuizQuestion(title: "Qui chante « …Baby One More Time » (1998) ?",
                         answers: ["Britney Spears"],
                         theme: "Années 2000", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse américaine", "Prénom : B*******"]),
            QuizQuestion(title: "Qui interprète « Wonderwall » (1995) ?",
                         answers: ["Oasis"],
                         theme: "Années 2000", difficulty: .facile, tone: nil,
                         indices: ["Groupe britannique des années 90", "Frères Gallagher"]),
            QuizQuestion(title: "Quel duo français est derrière « Around the World » (1997) ?",
                         answers: ["Daft Punk"],
                         theme: "Années 2000", difficulty: .moyen, tone: nil,
                         indices: ["Casques de robots", "French House"]),
            QuizQuestion(title: "Qui a sorti « Lose Yourself » (2002) ?",
                         answers: ["Eminem"],
                         theme: "Années 2000", difficulty: .facile, tone: nil,
                         indices: ["Rappeur de Detroit", "8 Mile"]),
            QuizQuestion(title: "Qui chante « Hips Don't Lie » (2006) ?",
                         answers: ["Shakira", "Wyclef Jean"],
                         theme: "Années 2000", difficulty: .moyen, tone: nil,
                         indices: ["Artiste colombienne", "Hanche qui ne ment pas…"]),
            QuizQuestion(title: "Quel groupe interprète « Bring Me to Life » (2003) ?",
                         answers: ["Evanescence"],
                         theme: "Années 2000", difficulty: .moyen, tone: nil,
                         indices: ["Rock gothique américain", "Chanteuse Amy L."]),
            QuizQuestion(title: "Qui chante « Umbrella » (2007) ?",
                         answers: ["Rihanna"],
                         theme: "Années 2000", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse de la Barbade", "Ella-ella-ella…"]),
            QuizQuestion(title: "Quel DJ français a sorti « Love Don't Let Me Go » (2002) ?",
                         answers: ["David Guetta"],
                         theme: "Années 2000", difficulty: .moyen, tone: nil,
                         indices: ["DJ parisien", "One Love (album)"]),
            QuizQuestion(title: "Qui chante « Toxic » (2003) ?",
                         answers: ["Britney Spears"],
                         theme: "Années 2000", difficulty: .facile, tone: nil,
                         indices: ["Même artiste que Baby One More Time", "Princesse de la pop"]),
            QuizQuestion(title: "Quel groupe est connu pour « Numb » (2003) ?",
                         answers: ["Linkin Park"],
                         theme: "Années 2000", difficulty: .moyen, tone: nil,
                         indices: ["Nu-metal américain", "Chester B. au chant"])
        ]
    )

    // MARK: Années 2010-2020

    static let music2010s = QuizSet(
        title: "Tubes des années 2010",
        theme: QuizThemes.annees2010,
        questions: [
            QuizQuestion(title: "Qui chante « Rolling in the Deep » (2010) ?",
                         answers: ["Adele"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse britannique", "Voix grave et puissante"]),
            QuizQuestion(title: "Qui interprète « Happy » (2013) ?",
                         answers: ["Pharrell Williams"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Producteur américain", "Bande originale de Minions"]),
            QuizQuestion(title: "Qui chante « Papaoutai » (2013) ?",
                         answers: ["Stromae"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Artiste belge", "Anagramme de maestro"]),
            QuizQuestion(title: "Quel duo français interprète « Get Lucky » (2013) ?",
                         answers: ["Daft Punk"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Casques de robots", "Thomas et Guy-Manuel"]),
            QuizQuestion(title: "Qui chante « Chandelier » (2014) ?",
                         answers: ["Sia"],
                         theme: "Années 2010", difficulty: .moyen, tone: nil,
                         indices: ["Chanteuse australienne", "Souvent cachée par une perruque"]),
            QuizQuestion(title: "Qui interprète « Starboy » (2016) ?",
                         answers: ["The Weeknd"],
                         theme: "Années 2010", difficulty: .moyen, tone: nil,
                         indices: ["Artiste canadien", "Abel T. de son vrai nom"]),
            QuizQuestion(title: "Qui chante « Shallow » (2018) ?",
                         answers: ["Lady Gaga", "Bradley Cooper"],
                         theme: "Années 2010", difficulty: .moyen, tone: nil,
                         indices: ["Bande originale d'A Star is Born", "Duo actrice-acteur"]),
            QuizQuestion(title: "Qui interprète « Despacito » (2017) ?",
                         answers: ["Luis Fonsi", "Daddy Yankee"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Artiste portoricain", "Un des clips les plus vus sur YouTube"]),
            QuizQuestion(title: "Qui chante « This Is America » (2018) ?",
                         answers: ["Childish Gambino", "Donald Glover"],
                         theme: "Années 2010", difficulty: .moyen, tone: nil,
                         indices: ["Acteur et rappeur américain", "Alias de Donald G."]),
            QuizQuestion(title: "Qui interprète « Shape of You » (2017) ?",
                         answers: ["Ed Sheeran"],
                         theme: "Années 2010", difficulty: .facile, tone: nil,
                         indices: ["Chanteur britannique roux", "Album ÷ (Divide)"])
        ]
    )

    // MARK: Pop FR

    static let setPopFR = QuizSet(
        title: "Variété & Pop françaises",
        theme: QuizThemes.popFR,
        questions: [
            QuizQuestion(title: "Qui chante « Djadja » (2018) ?",
                         answers: ["Aya Nakamura"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Artiste française d'origine malienne", "Prénom : A**"]),
            QuizQuestion(title: "Qui interprète « Balance ton quoi » (2019) ?",
                         answers: ["Angèle"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse belge", "Sœur de Roméo Elvis"]),
            QuizQuestion(title: "Qui chante « Nuit 17 à 52 » (2017) ?",
                         answers: ["Clara Luciani"],
                         theme: "Pop FR", difficulty: .moyen, tone: nil,
                         indices: ["Chanteuse française", "Née à Martigues"]),
            QuizQuestion(title: "Qui interprète « Papaoutai » (2013) ?",
                         answers: ["Stromae"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Artiste belge", "Anagramme de maestro"]),
            QuizQuestion(title: "Qui chante « Dernière danse » (2013) ?",
                         answers: ["Indila"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse française aux origines multiculturelles", "Prénom : Adila"]),
            QuizQuestion(title: "Qui interprète « La vie en rose » ?",
                         answers: ["Édith Piaf"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["La Môme", "Chanteuse française emblématique"]),
            QuizQuestion(title: "Qui chante « Les Champs-Élysées » ?",
                         answers: ["Joe Dassin"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Chanteur franco-américain", "Prénom : Joe"]),
            QuizQuestion(title: "Qui interprète « Je l'aime à mourir » ?",
                         answers: ["Francis Cabrel"],
                         theme: "Pop FR", difficulty: .moyen, tone: nil,
                         indices: ["Chanteur français du Sud-Ouest", "Guitare acoustique"]),
            QuizQuestion(title: "Qui chante « Ne me quitte pas » ?",
                         answers: ["Jacques Brel"],
                         theme: "Pop FR", difficulty: .facile, tone: nil,
                         indices: ["Chanteur belge", "Grand nom de la chanson française"]),
            QuizQuestion(title: "Qui interprète « Alexandrie Alexandra » ?",
                         answers: ["Claude François"],
                         theme: "Pop FR", difficulty: .moyen, tone: nil,
                         indices: ["Cloclo", "Il a aussi composé « My Way »"])
        ]
    )

    // MARK: Rock

    static let setRock = QuizSet(
        title: "Classiques du Rock",
        theme: QuizThemes.rock,
        questions: [
            QuizQuestion(title: "Quel groupe interprète « Bohemian Rhapsody » (1975) ?",
                         answers: ["Queen"],
                         theme: "Rock", difficulty: .facile, tone: nil,
                         indices: ["Groupe britannique légendaire", "Freddie M. au chant"]),
            QuizQuestion(title: "Qui chante « Stairway to Heaven » (1971) ?",
                         answers: ["Led Zeppelin"],
                         theme: "Rock", difficulty: .moyen, tone: nil,
                         indices: ["Groupe de hard rock britannique", "Guitariste Jimmy P."]),
            QuizQuestion(title: "Quel groupe interprète « Creep » (1993) ?",
                         answers: ["Radiohead"],
                         theme: "Rock", difficulty: .moyen, tone: nil,
                         indices: ["Rock alternatif britannique", "Thom Y. au chant"]),
            QuizQuestion(title: "Qui chante « Back in Black » (1980) ?",
                         answers: ["AC/DC"],
                         theme: "Rock", difficulty: .facile, tone: nil,
                         indices: ["Groupe australien de hard rock", "Brian Johnson au chant"]),
            QuizQuestion(title: "Quel groupe interprète « Come as You Are » (1991) ?",
                         answers: ["Nirvana"],
                         theme: "Rock", difficulty: .facile, tone: nil,
                         indices: ["Grunge de Seattle", "Kurt C. au chant"]),
            QuizQuestion(title: "Quel groupe chante « Hotel California » (1977) ?",
                         answers: ["Eagles"],
                         theme: "Rock", difficulty: .moyen, tone: nil,
                         indices: ["Groupe de rock américain", "Album éponyme"]),
            QuizQuestion(title: "Qui interprète « Sympathy for the Devil » (1968) ?",
                         answers: ["Rolling Stones", "The Rolling Stones"],
                         theme: "Rock", difficulty: .moyen, tone: nil,
                         indices: ["Groupe légendaire britannique", "Mick J. et Keith R."]),
            QuizQuestion(title: "Quel groupe est connu pour « Smells Like Teen Spirit » (1991) ?",
                         answers: ["Nirvana"],
                         theme: "Rock", difficulty: .facile, tone: nil,
                         indices: ["Grunge américain", "Album Nevermind"])
        ]
    )

    // MARK: Rap / Hip-Hop FR

    static let setRapFR = QuizSet(
        title: "Rap français incontournable",
        theme: QuizThemes.rapFR,
        questions: [
            QuizQuestion(title: "Qui chante « Suicide Social » (2015) ?",
                         answers: ["Orelsan"],
                         theme: "Rap FR", difficulty: .moyen, tone: nil,
                         indices: ["Rappeur normand", "Album Nantes"]),
            QuizQuestion(title: "Quel duo interprète « Da Silva » (2019) ?",
                         answers: ["PNL"],
                         theme: "Rap FR", difficulty: .moyen, tone: nil,
                         indices: ["Duo fraternel de la cité des 4000", "N.O.S et Ademo"]),
            QuizQuestion(title: "Qui chante « Défaite de famille » (2016) ?",
                         answers: ["Bigflo & Oli"],
                         theme: "Rap FR", difficulty: .facile, tone: nil,
                         indices: ["Duo de frères toulousains", "Album La Vraie Vie"]),
            QuizQuestion(title: "Qui interprète « Chocolat » (2019) ?",
                         answers: ["Ninho"],
                         theme: "Rap FR", difficulty: .moyen, tone: nil,
                         indices: ["Rappeur français", "Ninho S."]),
            QuizQuestion(title: "Qui chante « Jusqu'ici tout va bien » (1995) ?",
                         answers: ["IAM"],
                         theme: "Rap FR", difficulty: .moyen, tone: nil,
                         indices: ["Groupe de rap marseillais", "Akhenaton au micro"]),
            QuizQuestion(title: "Qui interprète « Jour de chance » (2012) ?",
                         answers: ["Nekfeu"],
                         theme: "Rap FR", difficulty: .difficile, tone: nil,
                         indices: ["Rappeur parisien", "Feutres noirs"]),
            QuizQuestion(title: "Quel rappeur est surnommé 'l'Ennemi Public' ?",
                         answers: ["Booba"],
                         theme: "Rap FR", difficulty: .moyen, tone: nil,
                         indices: ["DC Comics dans son univers", "Rap depuis les années 2000"])
        ]
    )

    // MARK: Électro / Dance

    static let setElectro = QuizSet(
        title: "Hits Électro & Dance",
        theme: QuizThemes.electro,
        questions: [
            QuizQuestion(title: "Quel duo français est derrière « Get Lucky » (2013) ?",
                         answers: ["Daft Punk"],
                         theme: "Électro", difficulty: .facile, tone: nil,
                         indices: ["Thomas et Guy-Manuel", "Casques de robots"]),
            QuizQuestion(title: "Qui interprète « Levels » (2011) ?",
                         answers: ["Avicii"],
                         theme: "Électro", difficulty: .facile, tone: nil,
                         indices: ["DJ suédois", "Prénom : Tim B."]),
            QuizQuestion(title: "Qui chante sur « Titanium » de David Guetta (2011) ?",
                         answers: ["Sia"],
                         theme: "Électro", difficulty: .moyen, tone: nil,
                         indices: ["Chanteuse australienne", "Cheveux blonds qui cachent le visage"]),
            QuizQuestion(title: "Quel groupe interprète « Don't You Worry Child » (2012) ?",
                         answers: ["Swedish House Mafia"],
                         theme: "Électro", difficulty: .moyen, tone: nil,
                         indices: ["Trio suédois", "Axwell, Steve Angello, Sebastian Ingrosso"]),
            QuizQuestion(title: "Qui interprète « Scary Monsters and Nice Sprites » (2010) ?",
                         answers: ["Skrillex"],
                         theme: "Électro", difficulty: .moyen, tone: nil,
                         indices: ["DJ américain de dubstep", "Moitié de la tête rasée"]),
            QuizQuestion(title: "Qui chante « One More Time » (2000) ?",
                         answers: ["Daft Punk"],
                         theme: "Électro", difficulty: .facile, tone: nil,
                         indices: ["Duo français", "Album Discovery"]),
            QuizQuestion(title: "Qui interprète « Lean On » (2015) feat. MO ?",
                         answers: ["Major Lazer"],
                         theme: "Électro", difficulty: .moyen, tone: nil,
                         indices: ["Collectif américain", "Diplo en est membre"])
        ]
    )

    // MARK: Lookup

    private static let allSets: [QuizSet] = [
        music80s, music90s, music2000s, music2010s,
        setPopFR, setRock, setRapFR, setElectro
    ]

    static func sets(for theme: QuizTheme) -> [QuizSet] {
        allSets.filter { $0.theme == theme }
    }
}
