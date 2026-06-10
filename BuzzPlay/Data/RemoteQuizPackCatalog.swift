//
//  RemoteQuizPackCatalog.swift
//  BuzzPlay
//
//  #v1-packs — packs de quiz fetchés silencieusement depuis un JSON public
//  (raw GitHub) au lancement de l'app, puis mis en cache localement → disponibles
//  hors-ligne pendant la partie. Aucune authentification, aucun compte.
//
//  Les packs avec `productID` sont premium (Non-Consumable, achat Master) ;
//  sans productID = gratuits. Le déblocage est géré par QuizPackStore.
//

import Foundation
import SwiftUI

// MARK: - JSON (format public hébergé sur GitHub — voir docs/quiz-packs-format.md)

private struct RemotePackCatalogJSON: Decodable {
    let packs: [RemotePackJSON]
}

private struct RemotePackJSON: Decodable {
    let id: String
    let title: String
    let iconName: String          // SF Symbol
    let category: String          // "era" | "genre" | libre (affichage seulement)
    let productID: String?        // ex "buzzplay.quiz.cinema" — absent = pack gratuit
    let priceDisplay: String?     // ex "0,99 €" (remplacé par le prix StoreKit en réel)
    let sets: [RemoteSetJSON]
}

private struct RemoteSetJSON: Decodable {
    let id: String
    let title: String
    let questions: [RemoteQuestionJSON]
}

// Format de question (historiquement celui de l'ex-quiz_sets.json local)
private struct RemoteQuestionJSON: Decodable {
    let question: String
    let answers: [String]
    let difficulty: String        // "facile" | "moyen" | "difficile" | "expert"
    let funFact: String?
}

// MARK: - Modèle runtime

struct RemoteQuizPack: Identifiable {
    let id: String
    let theme: QuizTheme          // construit UNE fois (identité stable pour sets(for:))
    let sets: [QuizSet]
    let productID: String?
    let priceDisplay: String?

    var isPremium: Bool { productID != nil }
}

// MARK: - Catalogue

@MainActor
@Observable
final class RemoteQuizPackCatalog {

    static let shared = RemoteQuizPackCatalog()

    /// URL publique du catalogue (fichier JSON raw sur GitHub).
    /// TODO(Romain) : pointer sur le vrai repo public de packs avant soumission.
    private static let catalogURL = URL(string:
        "https://raw.githubusercontent.com/Seravea/buzzplay-packs/main/quiz_packs.json")!

    private(set) var packs: [RemoteQuizPack] = []

    private init() {
        loadFromCache()
    }

    /// Fetch silencieux au lancement : toute erreur (offline, 404, JSON cassé) est
    /// ignorée — l'app vit sur le cache local, le jeu reste 100 % hors-ligne.
    func syncSilently() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let (data, response) = try await URLSession.shared.data(from: Self.catalogURL)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
                // Valide avant d'écraser le cache
                _ = try JSONDecoder().decode(RemotePackCatalogJSON.self, from: data)
                try data.write(to: Self.cacheFileURL(), options: .atomic)
                self.loadFromCache()
            } catch {
                print("RemoteQuizPackCatalog: sync silencieux ignoré (\(error.localizedDescription))")
            }
        }
    }

    func sets(for theme: QuizTheme) -> [QuizSet] {
        packs.first(where: { $0.theme == theme })?.sets ?? []
    }

    func pack(for theme: QuizTheme) -> RemoteQuizPack? {
        packs.first(where: { $0.theme == theme })
    }

    // MARK: - Cache local

    private static func cacheFileURL() throws -> URL {
        let dir = try FileManager.default.url(for: .applicationSupportDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: true)
        return dir.appendingPathComponent("quiz_packs_remote.json")
    }

    private func loadFromCache() {
        guard let url = try? Self.cacheFileURL(),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(RemotePackCatalogJSON.self, from: data) else {
            return
        }
        packs = catalog.packs.map { Self.buildPack(from: $0) }
    }

    // MARK: - JSON → modèles app

    private static func buildPack(from json: RemotePackJSON) -> RemoteQuizPack {
        let theme = QuizTheme(
            // id stable dérivé de l'id du pack → l'identité survit aux reloads
            id: UUID(uuidString: json.id) ?? stableUUID(from: json.id),
            title: json.title,
            iconName: json.iconName,
            color: color(for: json.category),
            category: json.category == "era" ? .era : .genre
        )
        let sets = json.sets.map { setJSON in
            QuizSet(
                id: UUID(uuidString: setJSON.id) ?? stableUUID(from: setJSON.id),
                title: setJSON.title,
                theme: theme,
                questions: setJSON.questions.map { q in
                    QuizQuestion(
                        title: q.question,
                        answers: q.answers,
                        theme: theme.title,
                        difficulty: QuizDifficulty(rawValue: q.difficulty) ?? .moyen,
                        tone: nil,
                        indices: [],
                        correctAnswers: q.answers,
                        funFact: q.funFact,
                        source: .bundled
                    )
                }
            )
        }
        return RemoteQuizPack(id: json.id, theme: theme, sets: sets,
                              productID: json.productID, priceDisplay: json.priceDisplay)
    }

    /// UUID déterministe depuis une chaîne (les ids du JSON ne sont pas forcément des UUIDs).
    private static func stableUUID(from string: String) -> UUID {
        var hash: UInt64 = 5381
        for byte in string.utf8 { hash = hash &* 33 &+ UInt64(byte) }
        let hex = String(format: "%016llx", hash)
        let uuidString = "\(hex.prefix(8))-\(hex.dropFirst(8).prefix(4))-4\(hex.dropFirst(12).prefix(3))-8000-000000000000"
        return UUID(uuidString: uuidString) ?? UUID()
    }

    private static func color(for category: String) -> Color {
        switch category {
        case "era":     return Color.blueLeading
        case "genre":   return Color.purpleLeading
        case "special": return Color.yellowLeading
        default:        return Color.purpleTrailing
        }
    }
}
