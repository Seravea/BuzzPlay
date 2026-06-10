//
//  QuizPromptBuilder.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import Foundation

func buildQuizPrompt(
    themes: [QuizTheme],
    difficulty: QuizDifficulty,
    count: Int,
    previousQuestions: [String] = []
) -> String {
    let themeLabel = themes.count == 1
        ? themes[0].title
        : "Mix \(themes.map(\.title).joined(separator: " / "))"

    let guidelines = themes.map(\.promptGuideline).joined(separator: "\n- ")
    let difficultyGuideline = difficulty.guideline

    let previousSection = previousQuestions.isEmpty ? "" : """

    QUESTIONS DÉJÀ POSÉES — NE PAS RÉPÉTER (ni la question, ni la même réponse) :
    \(previousQuestions.suffix(15).map { "- \($0)" }.joined(separator: "\n"))

    """

    return """
    Tu es un animateur de quiz musical pour une soirée entre amis en France.

    Génère exactement \(count) questions de quiz MUSICAL avec ces paramètres :
    - Thème : \(themeLabel)
    - Difficulté : \(difficulty.label) — \(difficultyGuideline)
    - Contexte thème(s) : \(guidelines)
    \(previousSection)
    RÈGLES STRICTES SUR LES QUESTIONS :
    1. Toutes les questions portent sur la MUSIQUE : artistes, albums, titres, concerts, hits, records, groupes
    2. Chaque question a UNE et UNE SEULE bonne réponse — pas d'ambiguïté possible
    3. La réponse est courte : 1 à 4 mots maximum
    4. La question doit être suffisamment précise pour que la réponse soit univoque
       → INTERDIT : "Quel est le titre d'une chanson de Michael Jackson ?" (trop vague)
       → CORRECT : "Quel album de Michael Jackson est le plus vendu de l'histoire ?" → "Thriller"
       → INTERDIT : "Quel artiste chante 'Shape of You' ?" si la réponse est dans la question
       → CORRECT : "Qui interprète le single numéro 1 de l'album ÷ (Divide) en 2017 ?" → "Ed Sheeran"
    5. Ne demande jamais "Un des titres de..." — toujours une seule réponse possible
    6. La réponse ne doit JAMAIS apparaître dans la question
    7. Pas de QCM — les joueurs répondent à l'oral
    8. Adapté à un public français de 18 à 35 ans en soirée
    9. Ton fun et décontracté, pas scolaire
    10. Pas de questions sur des événements après 2024
    11. Varie les types : "Qui", "Quel", "Dans quel", "Combien", "Quelle année", "Comment s'appelle"
    12. Chaque question ET chaque réponse doivent être uniques — ne reformule pas une question déjà posée, et ne donne pas la même réponse sous un autre intitulé

    ✅ BON EXEMPLE :
    Q: "Quel groupe a sorti l'album 'OK Computer' en 1997 ?" R: "Radiohead"

    ❌ À ÉVITER :
    - "Quel est le titre d'une chanson de Beyoncé ?" → trop vague, pas de réponse unique
    - "Dans quel film joue Lady Gaga ?" → pas musical
    """
}

// MARK: - Prompt guideline par thème musical

extension QuizTheme {
    var promptGuideline: String {
        switch title {
        case "Années 80":
            return "Hits et artistes iconiques des années 80. Pop, rock, dance, synthpop. Michael Jackson, Prince, Madonna, Queen, U2, AC/DC, Depeche Mode, a-ha, Wham!, Cyndi Lauper, Guns N' Roses."
        case "Années 90":
            return "Musique des années 90 tous genres. Grunge, techno, R&B, hip-hop, pop. Nirvana, Spice Girls, Backstreet Boys, NTM, IAM, Daft Punk, Whitney Houston, Oasis, Radiohead, Tupac."
        case "Années 2000":
            return "Tubes des années 2000. Pop, hip-hop, électro, rock alternatif. Eminem, Beyoncé, Britney Spears, Linkin Park, Rihanna, Amy Winehouse, Kanye West, David Guetta, Justin Timberlake."
        case "Années 2010-2020":
            return "Musique des années 2010-2020. Streaming, pop mondiale, rap FR. Drake, Stromae, Angèle, Ed Sheeran, Daft Punk, PNL, Adele, Pharrell, The Weeknd, Sia, Orelsan, Aya Nakamura."
        case "Pop FR":
            return "Variété et pop française de toutes les époques. Édith Piaf, Jacques Brel, Joe Dassin, Serge Gainsbourg, Claude François, Francis Cabrel, Stromae, Angèle, Aya Nakamura, Clara Luciani, Indila."
        case "Pop Internationale":
            return "Pop mondiale des 50 dernières années. Beatles, ABBA, Michael Jackson, Madonna, Beyoncé, Adele, Ed Sheeran, Taylor Swift, Lady Gaga, Billie Eilish."
        case "Rock":
            return "Rock de toutes les époques. Rolling Stones, Led Zeppelin, AC/DC, Queen, Nirvana, Radiohead, Metallica, Red Hot Chili Peppers, Foo Fighters, Arctic Monkeys."
        case "Rap / Hip-Hop FR":
            return "Rap français des années 90 à aujourd'hui. NTM, IAM, Booba, Rohff, Orelsan, PNL, Bigflo & Oli, Nekfeu, Ninho, SCH, Jul, Kaaris, Sofiane."
        case "Rap / Hip-Hop US":
            return "Hip-hop américain. Notorious B.I.G., Tupac, Jay-Z, Eminem, Kanye West, Drake, Kendrick Lamar, Cardi B, Travis Scott, Post Malone, J. Cole."
        case "Électro / Dance":
            return "Musique électronique et dance. Daft Punk, Avicii, David Guetta, Martin Garrix, Skrillex, Swedish House Mafia, Calvin Harris, Deadmau5, Justice, Disclosure."
        case "R&B / Soul":
            return "R&B, soul, funk. Stevie Wonder, Whitney Houston, Mariah Carey, Beyoncé, Alicia Keys, Usher, Rihanna, Bruno Mars, Frank Ocean, The Weeknd."
        case "K-Pop":
            return "K-Pop et musique coréenne. BTS, BLACKPINK, EXO, GOT7, TWICE, Stray Kids, aespa, (G)I-DLE. Records YouTube, membres, albums emblématiques."
        default:
            return "Questions musicales variées et amusantes."
        }
    }
}
