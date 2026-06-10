//
//  QuizPackStore.swift
//  BuzzPlay
//
//  #v1-packs — achat des packs de quiz premium (Non-Consumable, côté Master).
//  V1 = flow MOCKÉ (même pattern que l'ancien NotesStore) ; le vrai StoreKit 2
//  remplacera UNIQUEMENT performPurchase (le reste de l'API ne bouge pas).
//
//  Modèle retenu (bilan légal/produit) : on vend du CONTENU (packs thématiques,
//  ~0,99 €) comme Psych!/Heads Up! — pas de monnaie, pas de loot-box.
//

import Foundation

enum PackPurchaseState: Equatable {
    case idle
    case purchasing(String)   // productID en cours
    case success(String)      // productID acheté
    case failure
}

@MainActor
@Observable
final class QuizPackStore {

    static let shared = QuizPackStore()

    private static let unlockedKey = "buzzplay.quiz.unlockedPacks"

    var purchaseState: PackPurchaseState = .idle

    private(set) var unlockedProductIDs: Set<String> = {
        Set(UserDefaults.standard.stringArray(forKey: unlockedKey) ?? [])
    }() {
        didSet { UserDefaults.standard.set(Array(unlockedProductIDs), forKey: Self.unlockedKey) }
    }

    /// Un pack sans productID est gratuit → toujours débloqué.
    func isUnlocked(_ pack: RemoteQuizPack) -> Bool {
        guard let productID = pack.productID else { return true }
        return unlockedProductIDs.contains(productID)
    }

    func purchase(_ pack: RemoteQuizPack) {
        guard let productID = pack.productID else { return }
        guard case .idle = purchaseState else { return }
        Task { await performPurchase(productID) }
    }

    // MARK: - Purchase logic
    //
    // TODO: StoreKit 2 — remplacer le bloc MOCK par :
    //   let product = try await Product.products(for: [productID]).first
    //   let result = try await product.purchase()
    //   switch result { case .success(let verification): vérifier + unlock ... }
    // + restorePurchases() via Transaction.currentEntitlements (obligatoire Apple)
    // + Transaction.updates listener (achats hors-app / ask-to-buy).
    //
    private func performPurchase(_ productID: String) async {
        purchaseState = .purchasing(productID)

        // ── MOCK BEGIN ──────────────────────────────────────────────
        try? await Task.sleep(for: .seconds(1.2))
        let success = true   // false pour tester le chemin d'erreur
        // ── MOCK END ────────────────────────────────────────────────

        if success {
            unlockedProductIDs.insert(productID)
            purchaseState = .success(productID)
        } else {
            purchaseState = .failure
        }

        try? await Task.sleep(for: .seconds(1.5))
        purchaseState = .idle
    }

    /// Obligatoire Apple — branché sur Transaction.currentEntitlements en réel.
    func restorePurchases() {
        // MOCK : rien à restaurer (les unlocks vivent déjà dans UserDefaults).
    }
}
