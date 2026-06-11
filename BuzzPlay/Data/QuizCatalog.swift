//
//  QuizCatalog.swift
//  BuzzPlay
//
//  #v1-packs — source de vérité unifiée du contenu quiz : catégories in-app
//  (QuizThemes/QuizSamples) + packs distants (RemoteQuizPackCatalog), avec l'état
//  de verrou premium (QuizPackStore). DÉCISION Romain « les packs = les catégories » :
//  pas de section « Packs bonus » séparée, un pack s'affiche comme une catégorie.
//  Partagé par l'écran de sélection de thème ET le sélecteur de l'IA → une seule
//  définition de « la liste » et du « verrou ».
//

import Foundation

@MainActor
enum QuizCatalog {

    /// Liste unifiée des catégories, groupée par décennie / genre. Les packs distants
    /// s'insèrent dans leur groupe selon leur `category` (era/genre).
    static var groupedThemes: [(label: String, themes: [QuizTheme])] {
        let remoteThemes = RemoteQuizPackCatalog.shared.packs.map(\.theme)
        return [
            ("Par décennie", QuizThemes.eras + remoteThemes.filter { $0.category == .era }),
            ("Par genre", QuizThemes.genres + remoteThemes.filter { $0.category == .genre })
        ]
    }

    /// Sets jouables d'une catégorie : curatés in-app + pack distant (le cas échéant).
    static func sets(for theme: QuizTheme) -> [QuizSet] {
        QuizSamples.sets(for: theme) + RemoteQuizPackCatalog.shared.sets(for: theme)
    }

    /// Pack distant adossé à une catégorie (nil = catégorie purement in-app, gratuite).
    static func pack(for theme: QuizTheme) -> RemoteQuizPack? {
        RemoteQuizPackCatalog.shared.pack(for: theme)
    }

    /// Verrouillée ⇔ adossée à un pack premium non encore acheté. Le verrou vaut
    /// partout : carte de sélection ET sélecteur de l'IA (générer = avoir acheté).
    static func isLocked(_ theme: QuizTheme) -> Bool {
        guard let pack = pack(for: theme) else { return false }
        return !QuizPackStore.shared.isUnlocked(pack)
    }
}
