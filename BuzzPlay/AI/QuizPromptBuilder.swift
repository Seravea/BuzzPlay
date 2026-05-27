//
//  QuizPromptBuilder.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import Foundation

func buildQuizPrompt(
    theme: QuizTheme,
    difficulty: QuizDifficulty,
    count: Int,
    previousQuestions: [String] = []
) -> String {
    let themeGuideline = theme.promptGuideline
    let difficultyGuideline = difficulty.guideline

    let previousSection = previousQuestions.isEmpty ? "" : """

    QUESTIONS DÉJÀ POSÉES LORS DES PARTIES PRÉCÉDENTES — NE PAS RÉPÉTER :
    \(previousQuestions.prefix(60).enumerated().map { "- \($0.element)" }.joined(separator: "\n"))

    """

    return """
    Tu es un animateur de quiz pour une soirée entre amis en France.

    Génère exactement \(count) questions de quiz avec ces paramètres :
    - Thème : \(theme.title)
    - Difficulté : \(difficulty.label) — \(difficultyGuideline)
    - Contexte thème : \(themeGuideline)
    \(previousSection)
    RÈGLES STRICTES SUR LES QUESTIONS :
    1. Chaque question a UNE et UNE SEULE bonne réponse — pas d'ambiguïté possible
    2. La réponse est courte : 1 à 4 mots maximum
    3. La question doit être suffisamment précise pour que la réponse soit univoque
       → INTERDIT : "Quel est le titre d'une chanson de Ed Sheeran ?" (trop vague, plusieurs réponses valides)
       → INTERDIT : "Quel titre d'Ed Sheeran commence par 'I'm in love with the shape of you' ?" (la réponse est dans la question)
       → CORRECT : "Quel est le single le plus streamé d'Ed Sheeran sur son album ÷ (Divide) ?" → "Shape of You"
       → INTERDIT : "Dans quel film joue Leonardo DiCaprio ?" (trop vague)
       → CORRECT : "Dans quel film Leonardo DiCaprio incarne-t-il un prisonnier qui s'évade en 1966 ?" → "Papillon"
    4. Ne demande jamais "Un des titres de..." ou "Une chanson de..." — toujours une seule réponse possible
    5. La réponse ne doit JAMAIS apparaître dans la question, même partiellement (pas de citation du titre, pas de lyrics complets)
    6. Pas de QCM — les joueurs répondent à l'oral
    7. Adapté à un public français de 18 à 35 ans en soirée
    8. Ton fun et décontracté, pas scolaire
    9. Pas de questions sur des événements après 2024
    10. Le funFact doit être surprenant ou amusant — pas une reformulation de la réponse
    11. Varie les types : "Qui", "Quel", "Dans quel", "Combien", "Quelle année", "Comment s'appelle"
    12. Ne commence pas deux questions par la même formulation

    EXEMPLES DE BONNES QUESTIONS :

    ✅ Moyen / Cinéma :
    Q: "Qui a réalisé le film Inception ?"
    R: "Christopher Nolan"
    Anecdote: "Nolan a mis 10 ans à écrire le script et le film a été tourné dans 6 pays différents."

    ✅ Facile / Culture générale :
    Q: "Quelle est la plus grande planète du système solaire ?"
    R: "Jupiter"
    Anecdote: "Jupiter est si grande qu'on pourrait y mettre 1 300 Terres à l'intérieur."

    ✅ Difficile / Musique :
    Q: "Combien de semaines 'Thriller' de Michael Jackson est-il resté numéro 1 aux États-Unis ?"
    R: "37 semaines"
    Anecdote: "Thriller reste l'album le plus vendu de l'histoire avec plus de 70 millions de copies."

    ✅ Expert / Histoire :
    Q: "En quelle année la première page web a-t-elle été publiée par Tim Berners-Lee ?"
    R: "1991"
    Anecdote: "Tim Berners-Lee a créé le web pour partager des informations entre chercheurs du CERN."

    ❌ EXEMPLES DE MAUVAISES QUESTIONS (à ne jamais faire) :
    - "Quel est le titre d'une chanson de Beyoncé ?" → trop vague
    - "Dans quel film joue Brad Pitt ?" → trop vague
    - "Quel artiste chante 'Happy' ?" → acceptable si unique, mais préférer un contexte plus précis
    """
}

// Extension sur QuizTheme pour ajouter la guideline de prompt
extension QuizTheme {
    var promptGuideline: String {
        switch title {
        case "Culture générale":
            return "Mélange équilibré de tous les domaines. Évite le trop spécialisé."
        case "Cinéma & Séries":
            return "Films et séries connus du grand public. Réalisateurs, acteurs, répliques cultes, Oscars."
        case "Musique":
            return "Artistes, albums, chansons. Musique populaire, pas trop pointue."
        case "Sport":
            return "Football, tennis, F1, JO, rugby. Palmarès, records, champions emblématiques, équipes nationales. Privilégie les faits marquants bien connus."
        case "Histoire":
            return "Événements majeurs, personnages historiques. Évite les dates trop précises."
        case "Science & Nature":
            return "Découvertes, inventions, phénomènes naturels. Accessible, pas technique."
        case "Géographie":
            return "Capitales, fleuves, pays, continents. Géographie physique et humaine."
        case "Années 80-90":
            return "Pop culture des années 80 et 90. Musique, films, séries, mode, jeux."
        case "Gastronomie":
            return "Cuisine française et internationale. Plats, ingrédients, chefs célèbres."
        case "Jeux vidéo":
            return "Jeux cultes, personnages, studios. Accessible aux joueurs occasionnels."
        case "Art & Littérature":
            return "Peintres, écrivains, œuvres célèbres. Culture générale artistique."
        case "People & Célébrités":
            return "Célébrités françaises et internationales. Acteurs, chanteurs, sportifs."
        case "Pop Culture FR":
            return "Références françaises récentes : rap (Booba, PNL, SCH), séries (Kaamelott, HPI, Lupin), YouTubeurs, films français cultes. Accessible 18-35 ans."
        case "Années 90-2000":
            return "Nostalgie 25-40 ans. Club Dorothée, Pokémon, Tamagotchi, Skyrock, Loft Story, premières consoles, films de l'époque, groupes pop. Pas d'events post-2005."
        case "Réseaux & Mèmes":
            return "Internet culture : mèmes cultes, réseaux sociaux (Instagram, TikTok, Twitter), YouTubeurs, viral moments, records YouTube. Faits vérifiables uniquement."
        case "Gastronomie":
            return "Cuisine française et mondiale. Plats emblématiques, ingrédients, techniques, chefs célèbres, origines des recettes. Fun et accessible, pas trop technique."
        case "Jeux vidéo":
            return "Jeux iconiques : Mario, GTA, Minecraft, Fortnite, LoL, Zelda, Call of Duty. Personnages, studios, records de ventes. Accessible aux joueurs occasionnels."
        default:
            return "Questions variées et amusantes."
        }
    }
}
