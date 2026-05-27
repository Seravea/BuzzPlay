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

    static let sport = QuizTheme(
        title: "Sport",
        emoji: "⚽",
        color: Color(hex: "#00C950")
    )

    static let popCultureFR = QuizTheme(
        title: "Pop Culture FR",
        emoji: "📱",
        color: Color(hex: "#F6339A")
    )

    static let annees9000 = QuizTheme(
        title: "Années 90-2000",
        emoji: "📺",
        color: Color(hex: "#F0B100")
    )

    static let memes = QuizTheme(
        title: "Réseaux & Mèmes",
        emoji: "🌐",
        color: Color(hex: "#00B8DB")
    )

    static let gastro = QuizTheme(
        title: "Gastronomie",
        emoji: "🍕",
        color: Color(hex: "#FF6900")
    )

    static let jeuxVideo = QuizTheme(
        title: "Jeux vidéo",
        emoji: "🎮",
        color: Color(hex: "#2B7FFF")
    )

    static let rebus = QuizTheme(
        title: "Rébus",
        emoji: "🎭",
        color: Color(hex: "#AD46FF")
    )

    // Tier 1 + 4 thèmes clés 18-35 ans FR — 8 max en V1
    static let all: [QuizTheme] = [
        music, cinema, cultureG, sport,
        annees9000, popCultureFR, jeuxVideo, gastro
    ]
    // Réservés V1.5 : memes, rebus (saisonniers aussi)
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
                         theme: "Musique", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse américaine", "Prénom : B*******"]),
            QuizQuestion(title: "Qui interprète « Wonderwall » ?",
                         answers: ["Oasis"],
                         theme: "Musique", difficulty: .facile, tone: nil,
                         indices: ["Groupe britannique des années 90", "Frères Gallagher"]),
            QuizQuestion(title: "Quel duo français est derrière « Around the World » ?",
                         answers: ["Daft Punk"],
                         theme: "Musique", difficulty: .moyen, tone: nil,
                         indices: ["Casques de robots", "French House"]),
            QuizQuestion(title: "Qui a sorti « Lose Yourself » ?",
                         answers: ["Eminem"],
                         theme: "Musique", difficulty: .facile, tone: nil,
                         indices: ["Rappeur de Detroit", "8 Mile"]),
            QuizQuestion(title: "Qui chante « Hips Don't Lie » ?",
                         answers: ["Shakira", "Wyclef Jean"],
                         theme: "Musique", difficulty: .moyen, tone: nil,
                         indices: ["Artiste colombienne", "Hanche qui ne ment pas…"]),
            QuizQuestion(title: "Quel groupe interprète « Bring Me to Life » (2003) ?",
                         answers: ["Evanescence"],
                         theme: "Musique", difficulty: .moyen, tone: nil,
                         indices: ["Rock gothique américain", "Chanteuse Amy L."]),
            QuizQuestion(title: "Qui chante « Umbrella » ?",
                         answers: ["Rihanna", "Jay-Z"],
                         theme: "Musique", difficulty: .facile, tone: nil,
                         indices: ["Chanteuse de la Barbade", "Elle-ella-ella"]),
            QuizQuestion(title: "Quel DJ français a sorti « Love Don't Let Me Go » ?",
                         answers: ["David Guetta"],
                         theme: "Musique", difficulty: .moyen, tone: nil,
                         indices: ["DJ parisien", "One Love (album)"]),
            QuizQuestion(title: "Qui chante « Toxic » (2003) ?",
                         answers: ["Britney Spears"],
                         theme: "Musique", difficulty: .facile, tone: nil,
                         indices: ["Même artiste que « Baby One More Time »", "Princesse de la pop"]),
            QuizQuestion(title: "Quel groupe est connu pour « Numb » (2003) ?",
                         answers: ["Linkin Park"],
                         theme: "Musique", difficulty: .moyen, tone: nil,
                         indices: ["Nu-metal américain", "Chester B. au chant"])
        ]
    )

    static let musicFrench: QuizSet = QuizSet(
        title: "Variété française cultes",
        theme: QuizThemes.music,
        questions: [
            QuizQuestion(title: "Qui chante « Alexandrie Alexandra » ?",
                         answers: ["Claude François"],
                         theme: "Musique", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Qui interprète « Belle » dans Notre-Dame de Paris ?",
                         answers: ["Garou", "Daniel Lavoie", "Patrick Fiori"],
                         theme: "Musique", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Qui chante « Les Champs-Élysées » ?",
                         answers: ["Joe Dassin"],
                         theme: "Musique", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quel artiste français a composé « Je l'aime à mourir » ?",
                         answers: ["Francis Cabrel"],
                         theme: "Musique", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Qui chante « Ne me quitte pas » ?",
                         answers: ["Jacques Brel"],
                         theme: "Musique", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Qui interprète « Lettre à France » ?",
                         answers: ["Michel Polnareff"],
                         theme: "Musique", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Quel groupe français chante « Aux Champs-Élysées » version rock ?",
                         answers: ["Téléphone"],
                         theme: "Musique", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Qui chante « Dernière danse » (2013) ?",
                         answers: ["Indila"],
                         theme: "Musique", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Qui interprète « Papaoutai » ?",
                         answers: ["Stromae"],
                         theme: "Musique", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Qui chante « La vie en rose » ?",
                         answers: ["Édith Piaf"],
                         theme: "Musique", difficulty: .facile, tone: nil)
        ]
    )

    // MARK: Cinéma & Séries

    static let cinemaCult: QuizSet = QuizSet(
        title: "Répliques de films cultes",
        theme: QuizThemes.cinema,
        questions: [
            QuizQuestion(title: "« Je suis ton père » — dans quel film ?",
                         answers: ["Star Wars", "L'Empire contre-attaque"],
                         theme: "Cinéma", difficulty: .facile, tone: nil),
            QuizQuestion(title: "« Houston, on a un problème » — quel film ?",
                         answers: ["Apollo 13"],
                         theme: "Cinéma", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "« La vie, c'est comme une boîte de chocolats » — quel film ?",
                         answers: ["Forrest Gump"],
                         theme: "Cinéma", difficulty: .facile, tone: nil),
            QuizQuestion(title: "« Mon précieux » — quel personnage prononce cette phrase ?",
                         answers: ["Gollum"],
                         theme: "Cinéma", difficulty: .facile, tone: nil),
            QuizQuestion(title: "« T'as voulu voir Vesoul » — quel film français ?",
                         answers: ["Les Bronzés font du ski", "Les Bronzés"],
                         theme: "Cinéma", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "« Casse-toi pauvre con » — dans quel film cette réplique est détournée ?",
                         answers: ["OSS 117"],
                         theme: "Cinéma", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "« À demain ! À demain ! » — quel film des Inconnus ?",
                         answers: ["Les Trois Frères"],
                         theme: "Cinéma", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "« Je reviendrai » (I'll be back) — quel acteur ?",
                         answers: ["Arnold Schwarzenegger"],
                         theme: "Cinéma", difficulty: .facile, tone: nil),
            QuizQuestion(title: "« Ils sont fous ces Romains » — quelle saga ?",
                         answers: ["Astérix"],
                         theme: "Cinéma", difficulty: .facile, tone: nil),
            QuizQuestion(title: "« Tu es un sorcier, Harry » — qui dit cette phrase ?",
                         answers: ["Hagrid", "Rubeus Hagrid"],
                         theme: "Cinéma", difficulty: .facile, tone: nil)
        ]
    )

    static let seriesTV: QuizSet = QuizSet(
        title: "Séries TV à succès",
        theme: QuizThemes.cinema,
        questions: [
            QuizQuestion(title: "Dans quelle série suit-on Walter White, prof de chimie ?",
                         answers: ["Breaking Bad"],
                         theme: "Séries", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quelle série se déroule à Westeros ?",
                         answers: ["Game of Thrones", "Le Trône de fer"],
                         theme: "Séries", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Dans Friends, quel est le métier de Ross ?",
                         answers: ["Paléontologue"],
                         theme: "Séries", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quelle série espagnole met en scène un braquage de la Maison de la Monnaie ?",
                         answers: ["La Casa de Papel"],
                         theme: "Séries", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Dans Stranger Things, dans quelle ville fictive se passe l'action ?",
                         answers: ["Hawkins"],
                         theme: "Séries", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quel est le nom du dragon préféré de Daenerys ?",
                         answers: ["Drogon"],
                         theme: "Séries", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Dans The Office (US), qui joue Michael Scott ?",
                         answers: ["Steve Carell"],
                         theme: "Séries", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Dans Kaamelott, qui joue le roi Arthur ?",
                         answers: ["Alexandre Astier"],
                         theme: "Séries", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Dans Peaky Blinders, quel est le nom de famille de la bande ?",
                         answers: ["Shelby"],
                         theme: "Séries", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quelle série Netflix suit une joueuse d'échecs orpheline ?",
                         answers: ["Le Jeu de la dame", "The Queen's Gambit"],
                         theme: "Séries", difficulty: .moyen, tone: nil)
        ]
    )

    // MARK: Culture G

    static let cultureGeoHistoire: QuizSet = QuizSet(
        title: "Histoire & géographie",
        theme: QuizThemes.cultureG,
        questions: [
            QuizQuestion(title: "En quelle année la Révolution française a-t-elle débuté ?",
                         answers: ["1789"],
                         theme: "Histoire", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quelle est la capitale de l'Australie ?",
                         answers: ["Canberra"],
                         theme: "Géographie", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Qui était le premier homme à marcher sur la Lune ?",
                         answers: ["Neil Armstrong"],
                         theme: "Histoire", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quel fleuve traverse Paris ?",
                         answers: ["La Seine", "Seine"],
                         theme: "Géographie", difficulty: .facile, tone: nil),
            QuizQuestion(title: "En quelle année le mur de Berlin est-il tombé ?",
                         answers: ["1989"],
                         theme: "Histoire", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quel est le plus grand désert du monde ?",
                         answers: ["L'Antarctique", "Antarctique"],
                         theme: "Géographie", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Quel empereur a construit la Grande Muraille de Chine ?",
                         answers: ["Qin Shi Huang", "Qin Shi Huangdi"],
                         theme: "Histoire", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Dans quel pays se trouve le Machu Picchu ?",
                         answers: ["Pérou", "Le Pérou"],
                         theme: "Géographie", difficulty: .facile, tone: nil),
            QuizQuestion(title: "En quelle année a eu lieu la bataille de Waterloo ?",
                         answers: ["1815"],
                         theme: "Histoire", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quelle est la plus longue rivière du monde ?",
                         answers: ["Le Nil", "Nil"],
                         theme: "Géographie", difficulty: .moyen, tone: nil)
        ]
    )

    static let cultureSciences: QuizSet = QuizSet(
        title: "Sciences & nature",
        theme: QuizThemes.cultureG,
        questions: [
            QuizQuestion(title: "Quelle est la formule chimique de l'eau ?",
                         answers: ["H2O"],
                         theme: "Sciences", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quelle planète est la plus proche du Soleil ?",
                         answers: ["Mercure"],
                         theme: "Sciences", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Combien d'os compte le corps humain adulte ?",
                         answers: ["206"],
                         theme: "Sciences", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Quel est le métal liquide à température ambiante ?",
                         answers: ["Mercure"],
                         theme: "Sciences", difficulty: .moyen, tone: nil),
            QuizQuestion(title: "Qui a formulé la théorie de la relativité ?",
                         answers: ["Albert Einstein", "Einstein"],
                         theme: "Sciences", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quel est l'animal terrestre le plus rapide ?",
                         answers: ["Le guépard", "Guépard"],
                         theme: "Nature", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Combien de cœurs possède une pieuvre ?",
                         answers: ["3", "Trois"],
                         theme: "Nature", difficulty: .difficile, tone: nil),
            QuizQuestion(title: "Quel gaz les plantes absorbent-elles pour la photosynthèse ?",
                         answers: ["Le dioxyde de carbone", "CO2", "Dioxyde de carbone"],
                         theme: "Sciences", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quel est le plus grand océan du monde ?",
                         answers: ["L'océan Pacifique", "Pacifique"],
                         theme: "Nature", difficulty: .facile, tone: nil),
            QuizQuestion(title: "Quelle est l'unité de mesure de la force électrique ?",
                         answers: ["L'ampère", "Ampère"],
                         theme: "Sciences", difficulty: .moyen, tone: nil)
        ]
    )

    // MARK: Sport

    static let sportChampions: QuizSet = QuizSet(
        title: "Champions & Records",
        theme: QuizThemes.sport,
        questions: [
            QuizQuestion(title: "Quel pays a remporté la Coupe du Monde de football en 1998 ?",
                         answers: ["La France", "France"],
                         theme: "Sport", difficulty: .facile, tone: nil,
                         funFact: "Zinedine Zidane a marqué deux buts de la tête en finale. Score : 3-0 contre le Brésil."),
            QuizQuestion(title: "Combien de titres de champion du monde de F1 Lewis Hamilton détient-il ?",
                         answers: ["7", "Sept"],
                         theme: "Sport", difficulty: .moyen, tone: nil,
                         funFact: "Il a égalé le record légendaire de Michael Schumacher avec 7 titres mondiaux en 2020."),
            QuizQuestion(title: "Dans quelle ville se sont déroulés les Jeux Olympiques d'été 2024 ?",
                         answers: ["Paris"],
                         theme: "Sport", difficulty: .facile, tone: nil,
                         funFact: "C'était la 3e fois que Paris accueillait les JO d'été, après 1900 et 1924."),
            QuizQuestion(title: "Quel club a remporté le plus de Ligues des Champions UEFA ?",
                         answers: ["Real Madrid", "Le Real Madrid"],
                         theme: "Sport", difficulty: .facile, tone: nil,
                         funFact: "Le Real Madrid a remporté 15 Ligues des Champions, dont 3 consécutives de 2016 à 2018."),
            QuizQuestion(title: "En quelle année Zinedine Zidane a-t-il reçu un carton rouge en finale de Coupe du Monde ?",
                         answers: ["2006"],
                         theme: "Sport", difficulty: .moyen, tone: nil,
                         funFact: "Ce coup de tête contre Marco Materazzi reste l'un des moments les plus marquants de l'histoire du foot."),
            QuizQuestion(title: "Quelle nation a remporté le plus de Coupes du Monde de rugby ?",
                         answers: ["Nouvelle-Zélande", "Les All Blacks"],
                         theme: "Sport", difficulty: .moyen, tone: nil,
                         funFact: "Les All Blacks ont remporté le titre en 1987, 2011 et 2015."),
            QuizQuestion(title: "Quel tennisman détient le record du plus grand nombre de titres en Grand Chelem ?",
                         answers: ["Novak Djokovic", "Djokovic"],
                         theme: "Sport", difficulty: .difficile, tone: nil,
                         funFact: "Djokovic a remporté 24 titres du Grand Chelem, dépassant Federer (20) et Nadal (22)."),
        ]
    )

    // MARK: Pop Culture FR

    static let popCultureFRSet: QuizSet = QuizSet(
        title: "Made in France",
        theme: QuizThemes.popCultureFR,
        questions: [
            QuizQuestion(title: "Dans la série Kaamelott, qui joue le roi Arthur ?",
                         answers: ["Alexandre Astier"],
                         theme: "Pop Culture FR", difficulty: .facile, tone: nil,
                         funFact: "Alexandre Astier a écrit, réalisé et joué dans Kaamelott. Il a tourné plus de 458 épisodes."),
            QuizQuestion(title: "Quel groupe de rap français est connu pour les titres 'Le Lac' et 'Da' ?",
                         answers: ["PNL"],
                         theme: "Pop Culture FR", difficulty: .facile, tone: nil,
                         funFact: "PNL (Deux Frères) est le duo formé par Ademo et N.O.S, deux frères originaires de Tarterêts."),
            QuizQuestion(title: "Quelle émission TV française a révélé Jenifer Bartoli en 2002 ?",
                         answers: ["Star Academy"],
                         theme: "Pop Culture FR", difficulty: .facile, tone: nil,
                         funFact: "Star Academy saison 1 a battu des records d'audience avec plus de 10 millions de téléspectateurs pour la finale."),
            QuizQuestion(title: "Quel rappeur français est surnommé 'le Duc de Boulogne' ?",
                         answers: ["Booba"],
                         theme: "Pop Culture FR", difficulty: .moyen, tone: nil,
                         funFact: "Booba est l'un des artistes les plus certifiés de l'histoire du rap français avec plus de 5 millions d'albums vendus."),
            QuizQuestion(title: "Quel est le vrai prénom du YouTubeur français connu sous le pseudonyme Squeezie ?",
                         answers: ["Lucas", "Lucas Hauchard"],
                         theme: "Pop Culture FR", difficulty: .moyen, tone: nil,
                         funFact: "Squeezie est le YouTubeur français le plus suivi avec plus de 18 millions d'abonnés."),
            QuizQuestion(title: "Dans quel film Jean Dujardin incarne-t-il un espion français maladroit des années 60 ?",
                         answers: ["OSS 117"],
                         theme: "Pop Culture FR", difficulty: .facile, tone: nil,
                         funFact: "OSS 117 : Le Caire, nid d'espions (2006) a relancé la carrière de Jean Dujardin qui a enchaîné avec The Artist."),
            QuizQuestion(title: "Quel est le vrai prénom de Bigflo, du duo Bigflo & Oli ?",
                         answers: ["Florian"],
                         theme: "Pop Culture FR", difficulty: .difficile, tone: nil,
                         funFact: "Bigflo (Florian) et Oli (Olivio) sont deux frères toulousains. 'La Cour des grands' a été disque de platine."),
        ]
    )

    // MARK: Années 90-2000

    static let annees9000Set: QuizSet = QuizSet(
        title: "Nostalgie 90-2000",
        theme: QuizThemes.annees9000,
        questions: [
            QuizQuestion(title: "Quel Pokémon porte le numéro 25 dans le Pokédex ?",
                         answers: ["Pikachu"],
                         theme: "Années 90-2000", difficulty: .facile, tone: nil,
                         funFact: "Pikachu est devenu la mascotte officielle de la franchise Pokémon depuis les débuts du dessin animé en 1997."),
            QuizQuestion(title: "Quel groupe britannique a chanté 'Wannabe' en 1996 ?",
                         answers: ["Spice Girls"],
                         theme: "Années 90-2000", difficulty: .facile, tone: nil,
                         funFact: "'Wannabe' est resté numéro 1 pendant 7 semaines au Royaume-Uni. C'est l'un des singles féminins les plus vendus de l'histoire."),
            QuizQuestion(title: "En quelle année est sorti le premier film de la saga Harry Potter ?",
                         answers: ["2001"],
                         theme: "Années 90-2000", difficulty: .facile, tone: nil,
                         funFact: "Harry Potter à l'école des sorciers a rapporté 975 millions de dollars mondial. Daniel Radcliffe avait 12 ans au tournage."),
            QuizQuestion(title: "Quel jeu de simulation de vie a été lancé par Maxis en 2000 ?",
                         answers: ["Les Sims", "The Sims"],
                         theme: "Années 90-2000", difficulty: .moyen, tone: nil,
                         funFact: "Les Sims ont vendu plus de 200 millions d'exemplaires toutes versions confondues, ce qui en fait l'un des jeux les plus vendus de l'histoire."),
            QuizQuestion(title: "Qui animait 'Le Club Dorothée' sur TF1 dans les années 80-90 ?",
                         answers: ["Dorothée"],
                         theme: "Années 90-2000", difficulty: .facile, tone: nil,
                         funFact: "Le Club Dorothée a duré de 1987 à 1997, diffusant Dragon Ball Z, Sailor Moon et Saint Seiya pour la première fois en France."),
            QuizQuestion(title: "En quelle année Google a-t-il été fondé par Larry Page et Sergey Brin ?",
                         answers: ["1998"],
                         theme: "Années 90-2000", difficulty: .moyen, tone: nil,
                         funFact: "Google a été créé dans un garage en Californie. Leur premier serveur était fait de pièces LEGO pour être facilement extensible."),
            QuizQuestion(title: "Quel groupe a chanté 'Bye Bye Bye' en 2000 ?",
                         answers: ["NSYNC", "*NSYNC"],
                         theme: "Années 90-2000", difficulty: .moyen, tone: nil,
                         funFact: "Justin Timberlake était membre de *NSYNC avant de lancer sa carrière solo avec 'Cry Me a River' en 2002."),
        ]
    )

    // MARK: Réseaux & Mèmes

    static let memesInternetSet: QuizSet = QuizSet(
        title: "Internet & Mèmes",
        theme: QuizThemes.memes,
        questions: [
            QuizQuestion(title: "En quelle année YouTube a-t-il été créé ?",
                         answers: ["2005"],
                         theme: "Réseaux & Mèmes", difficulty: .moyen, tone: nil,
                         funFact: "La première vidéo uploadée sur YouTube s'intitule 'Me at the zoo' et dure 18 secondes. Elle a été postée par le cofondateur Jawed Karim."),
            QuizQuestion(title: "Quel chanteur est associé au phénomène du 'Rickrolling' sur internet ?",
                         answers: ["Rick Astley"],
                         theme: "Réseaux & Mèmes", difficulty: .facile, tone: nil,
                         funFact: "Le Rickrolling consiste à partager un faux lien qui redirige vers 'Never Gonna Give You Up'. En 2023, la vidéo a dépassé le milliard de vues."),
            QuizQuestion(title: "Combien de caractères maximum permettait un tweet avant novembre 2017 ?",
                         answers: ["140"],
                         theme: "Réseaux & Mèmes", difficulty: .moyen, tone: nil,
                         funFact: "Twitter a doublé la limite à 280 caractères en 2017. La limite initiale de 140 venait des SMS qui permettaient 160 caractères."),
            QuizQuestion(title: "Dans quel pays TikTok a-t-il été créé ?",
                         answers: ["Chine"],
                         theme: "Réseaux & Mèmes", difficulty: .facile, tone: nil,
                         funFact: "TikTok a été créé par ByteDance en 2016 sous le nom Douyin en Chine. Il s'appelle TikTok dans le reste du monde depuis 2017."),
            QuizQuestion(title: "Quel réseau social a lancé le concept des 'Stories' éphémères en premier ?",
                         answers: ["Snapchat"],
                         theme: "Réseaux & Mèmes", difficulty: .moyen, tone: nil,
                         funFact: "Snapchat a lancé les Stories en 2013. Instagram les a copiées en 2016, et elles ont depuis dépassé Snapchat en nombre d'utilisateurs actifs."),
            QuizQuestion(title: "En quelle année Instagram a-t-il été racheté par Facebook ?",
                         answers: ["2012"],
                         theme: "Réseaux & Mèmes", difficulty: .difficile, tone: nil,
                         funFact: "Facebook a racheté Instagram pour 1 milliard de dollars en 2012. Instagram valait plus de 100 milliards 10 ans plus tard."),
            QuizQuestion(title: "De quel animal vient le mème 'This is fine' (chien devant un incendie) ?",
                         answers: ["Un chien", "Chien"],
                         theme: "Réseaux & Mèmes", difficulty: .facile, tone: nil,
                         funFact: "Ce mème vient d'un comic strip de KC Green (2013) où un chien dit 'This is fine' en buvant son café, entouré de flammes."),
        ]
    )

    // MARK: Gastronomie

    static let gastroSaveurs: QuizSet = QuizSet(
        title: "Cuisine & Saveurs",
        theme: QuizThemes.gastro,
        questions: [
            QuizQuestion(title: "Dans quelle ville française est née la bouillabaisse ?",
                         answers: ["Marseille"],
                         theme: "Gastronomie", difficulty: .facile, tone: nil,
                         funFact: "La bouillabaisse est une soupe de poisson originaire de Marseille. Son nom vient du provençal 'bolhabaissa' (faire bouillir et abaisser le feu)."),
            QuizQuestion(title: "Quelle épice donne la couleur jaune vif au curry ?",
                         answers: ["Le curcuma", "Curcuma"],
                         theme: "Gastronomie", difficulty: .moyen, tone: nil,
                         funFact: "Le curcuma est utilisé depuis plus de 4 000 ans. Il a des propriétés anti-inflammatoires reconnues par la science moderne."),
            QuizQuestion(title: "Quel pays africain est le plus grand producteur mondial de cacao ?",
                         answers: ["Côte d'Ivoire"],
                         theme: "Gastronomie", difficulty: .difficile, tone: nil,
                         funFact: "La Côte d'Ivoire produit environ 40% du cacao mondial, soit l'équivalent de 2 millions de tonnes par an."),
            QuizQuestion(title: "Quel est l'ingrédient principal du guacamole ?",
                         answers: ["Avocat", "L'avocat"],
                         theme: "Gastronomie", difficulty: .facile, tone: nil,
                         funFact: "Le mot 'guacamole' vient du nahuatl 'āhuacamōlli' qui signifie littéralement 'sauce d'avocat'. Les Aztèques le préparaient déjà il y a 500 ans."),
            QuizQuestion(title: "Quel fromage normand emblématique est vendu dans une boîte ronde en bois ?",
                         answers: ["Le camembert", "Camembert"],
                         theme: "Gastronomie", difficulty: .facile, tone: nil,
                         funFact: "La boîte en bois du camembert a été inventée en 1890 pour permettre son transport jusqu'aux États-Unis sans l'abîmer."),
            QuizQuestion(title: "Quelle ville française est souvent surnommée 'capitale mondiale de la gastronomie' ?",
                         answers: ["Lyon"],
                         theme: "Gastronomie", difficulty: .facile, tone: nil,
                         funFact: "Lyon abrite plus de 4 000 restaurants dont plusieurs étoilés Michelin. Paul Bocuse, né près de Lyon, a révolutionné la cuisine française."),
            QuizQuestion(title: "D'où vient originellement le sushi ?",
                         answers: ["Japon", "Du Japon"],
                         theme: "Gastronomie", difficulty: .facile, tone: nil,
                         funFact: "Le sushi moderne (nigiri) a été inventé à Tokyo (alors Edo) vers 1820 par Hanaya Yohei comme repas rapide à emporter."),
        ]
    )

    // MARK: Jeux vidéo

    static let jeuxVideoSet: QuizSet = QuizSet(
        title: "Pixel Masters",
        theme: QuizThemes.jeuxVideo,
        questions: [
            QuizQuestion(title: "Quel est le prénom du plombier emblématique de Nintendo ?",
                         answers: ["Mario"],
                         theme: "Jeux vidéo", difficulty: .facile, tone: nil,
                         funFact: "Mario s'appelait 'Jumpman' dans Donkey Kong (1981). Son nom vient de Mario Segale, le propriétaire de l'entrepôt de Nintendo USA."),
            QuizQuestion(title: "Dans quel jeu de RPG joue-t-on Geralt de Riv ?",
                         answers: ["The Witcher", "Le Sorceleur"],
                         theme: "Jeux vidéo", difficulty: .facile, tone: nil,
                         funFact: "The Witcher 3 a remporté plus de 250 récompenses du jeu de l'année. Il est basé sur les romans polonais d'Andrzej Sapkowski."),
            QuizQuestion(title: "En quelle année Minecraft a-t-il été officiellement lancé ?",
                         answers: ["2011"],
                         theme: "Jeux vidéo", difficulty: .moyen, tone: nil,
                         funFact: "Minecraft est le jeu le plus vendu de l'histoire avec plus de 238 millions d'exemplaires. Il a été créé par Markus 'Notch' Persson en Suède."),
            QuizQuestion(title: "Quel jeu battle royale met 100 joueurs en compétition sur une île ?",
                         answers: ["Fortnite"],
                         theme: "Jeux vidéo", difficulty: .facile, tone: nil,
                         funFact: "Fortnite a atteint 350 millions de joueurs en 2020. Le concert virtuel de Travis Scott dans le jeu a réuni 12 millions de spectateurs simultanés."),
            QuizQuestion(title: "Comment s'appelle le monstre vert explosif emblématique de Minecraft ?",
                         answers: ["Creeper"],
                         theme: "Jeux vidéo", difficulty: .facile, tone: nil,
                         funFact: "Le Creeper est né d'un bug : Notch avait inversé la hauteur et la largeur d'un cochon par erreur, créant cette silhouette verte caractéristique."),
            QuizQuestion(title: "Quelle console Nintendo lancée en 2017 peut s'utiliser aussi bien à la maison qu'en portable ?",
                         answers: ["Nintendo Switch"],
                         theme: "Jeux vidéo", difficulty: .facile, tone: nil,
                         funFact: "La Nintendo Switch a dépassé les 140 millions d'unités vendues, devenant la console la plus vendue de l'histoire de Nintendo."),
            QuizQuestion(title: "Dans quelle ville japonaise se trouve le siège de Nintendo ?",
                         answers: ["Kyoto"],
                         theme: "Jeux vidéo", difficulty: .difficile, tone: nil,
                         funFact: "Nintendo a été fondée à Kyoto en 1889... comme fabricant de cartes à jouer hanafuda. Elle n'est entrée dans le jeu vidéo qu'en 1977."),
        ]
    )

    // MARK: Rébus Films

    static let rebusFilms: QuizSet = QuizSet(
        title: "Films en emojis",
        theme: QuizThemes.rebus,
        questions: [
            QuizQuestion(
                title: "Quel film Disney se cache ici ?",
                answers: ["Le Roi Lion"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["🦁", "👑"],
                correctAnswer: "Le Roi Lion",
                funFact: "Le film est inspiré de Hamlet de Shakespeare et a rapporté 968M$ en 1994.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel film d'animation est caché ici ?",
                answers: ["La Reine des Neiges"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["❄️", "👸"],
                correctAnswer: "La Reine des Neiges",
                funFact: "'Let It Go' a été traduite en 42 langues différentes pour les versions locales du film.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel super-héros se cache ici ?",
                answers: ["Spider-Man"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["🕷️", "🧑"],
                correctAnswer: "Spider-Man",
                funFact: "Le costume de Spider-Man dans le film de 2002 a coûté 100 000 dollars à fabriquer.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel film Pixar se cache ici ?",
                answers: ["Le Monde de Nemo"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["🐠", "🔍"],
                correctAnswer: "Le Monde de Nemo",
                funFact: "Le film a déclenché une hausse de 40% des ventes de poissons-clowns dans les animaleries.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel conte Disney est représenté ici ?",
                answers: ["La Belle et la Bête"],
                theme: "Rébus",
                difficulty: .moyen,
                tone: nil,
                indices: ["🌹", "🧌"],
                correctAnswer: "La Belle et la Bête",
                funFact: "La bibliothèque de la Bête dans le film contient plus de 2 000 livres selon les créateurs.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel film de science-fiction est caché ici ?",
                answers: ["Matrix"],
                theme: "Rébus",
                difficulty: .moyen,
                tone: nil,
                indices: ["💊", "🔴", "🕶️"],
                correctAnswer: "Matrix",
                funFact: "Les Wachowski ont présenté 90 pages de storyboards pour convaincre le studio. Le budget initial était de 63 millions de dollars.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel blockbuster est caché ici ?",
                answers: ["Jurassic Park"],
                theme: "Rébus",
                difficulty: .moyen,
                tone: nil,
                indices: ["🦕", "🏝️"],
                correctAnswer: "Jurassic Park",
                funFact: "Le rugissement du T-Rex est un mélange de sons de tigre, d'alligator et d'éléphant enregistrés par les équipes sonores.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel film culte est représenté ici ?",
                answers: ["Titanic"],
                theme: "Rébus",
                difficulty: .moyen,
                tone: nil,
                indices: ["🚢", "🧊", "❄️"],
                correctAnswer: "Titanic",
                funFact: "James Cameron a plongé 33 fois sur l'épave du vrai Titanic pour préparer le film.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quel film d'animation est caché ici ?",
                answers: ["Kung Fu Panda"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["🐼", "🥋"],
                correctAnswer: "Kung Fu Panda",
                funFact: "Jack Black a mangé de vraies nouilles pendant l'enregistrement pour rendre son jeu d'acteur plus authentique.",
                questionType: .rebus
            ),
            QuizQuestion(
                title: "Quelle saga légendaire se cache ici ?",
                answers: ["Harry Potter"],
                theme: "Rébus",
                difficulty: .facile,
                tone: nil,
                indices: ["🧙", "⚡", "📖"],
                correctAnswer: "Harry Potter",
                funFact: "J.K. Rowling a imaginé l'histoire de Harry Potter pendant un retard de train de 4 heures entre Manchester et Londres en 1990.",
                questionType: .rebus
            ),
        ]
    )

    // MARK: - All

    static let all: [QuizSet] = [
        music2000s, musicFrench,
        cinemaCult, seriesTV,
        cultureGeoHistoire, cultureSciences,
        sportChampions,
        popCultureFRSet,
        annees9000Set,
        memesInternetSet,
        gastroSaveurs,
        jeuxVideoSet,
        rebusFilms
    ]

    /// Tous les sets d'un thème donné.
    static func sets(for theme: QuizTheme) -> [QuizSet] {
        all.filter { $0.theme == theme }
    }
}
