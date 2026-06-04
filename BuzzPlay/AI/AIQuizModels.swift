//
//  AIQuizModels.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import Foundation

#if os(iOS) && swift(>=5.9)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct AIQuizQuestion {
    @Guide(description: """
        La question posée oralement au Master. Claire, sans ambiguïté.
        Une et une seule bonne réponse. Pas de QCM.
        Adapté à une soirée entre amis français 18-35 ans.
        """)
    let question: String

    @Guide(description: """
        Réponse correcte uniquement. Courte et précise — 1 à 4 mots idéalement.
        Pas de phrase complète, pas d'article si possible.
        Exemples : "James Cameron", "1969", "Le Brésil", "Marie Curie"
        """)
    let correctAnswer: String

    @Guide(.anyOf(["facile", "moyen", "difficile", "expert"]))
    let difficulty: String
}

@available(iOS 26.0, *)
@Generable
struct AIGeneratedQuiz {
    @Guide(description: "Liste de questions de quiz sur le thème demandé")
    let questions: [AIQuizQuestion]
}
#endif
