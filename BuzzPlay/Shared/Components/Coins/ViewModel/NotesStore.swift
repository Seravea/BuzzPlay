//
//  NotesStore.swift
//  BuzzPlay
//

import Foundation

// MARK: - NotesPack

struct NotesPack: Identifiable {
    let id: String           // futur product ID StoreKit 2
    let notes: Int
    let priceDisplay: String
    let isBestValue: Bool

    /// Ratio notes/centime — pour afficher la valeur relative
    var notesPerEuro: Int { Int(Double(notes) / priceInEuros) }

    private var priceInEuros: Double {
        switch id {
        case "buzzplay.notes.intro":   return 0.99
        case "buzzplay.notes.soiree":  return 2.99
        case "buzzplay.notes.weekend": return 5.99
        case "buzzplay.notes.saison":  return 9.99
        default:                       return 1
        }
    }
}

// MARK: - PurchaseState

enum PurchaseState: Equatable {
    case idle
    case purchasing(String)  // pack ID en cours
    case success(Int)        // notes ajoutées
    case failure
}

// MARK: - NotesStore

@MainActor
@Observable
final class NotesStore {

    private weak var masterFlowVM: MasterFlowViewModel?

    let packs: [NotesPack] = [
        NotesPack(id: "buzzplay.notes.intro",   notes: 150,  priceDisplay: "0,99 €", isBestValue: false),
        NotesPack(id: "buzzplay.notes.soiree",  notes: 450,  priceDisplay: "2,99 €", isBestValue: true),
        NotesPack(id: "buzzplay.notes.weekend", notes: 1200, priceDisplay: "5,99 €", isBestValue: false),
        NotesPack(id: "buzzplay.notes.saison",  notes: 3000, priceDisplay: "9,99 €", isBestValue: false),
    ]

    var purchaseState: PurchaseState = .idle

    init(masterFlowVM: MasterFlowViewModel) {
        self.masterFlowVM = masterFlowVM
    }

    func purchase(_ pack: NotesPack) {
        guard case .idle = purchaseState else { return }
        Task { await performPurchase(pack) }
    }

    // MARK: - Purchase logic
    //
    // TODO: StoreKit 2 — remplacer le bloc "MOCK" ci-dessous par :
    //   let result = try await pack.skProduct.purchase()
    //   switch result { case .success(let verification): ... }
    //
    private func performPurchase(_ pack: NotesPack) async {
        purchaseState = .purchasing(pack.id)

        // ── MOCK BEGIN ──────────────────────────────────────────────
        try? await Task.sleep(for: .seconds(1.2))
        let success = true   // toujours succès en mock — false pour tester l'erreur
        // ── MOCK END ────────────────────────────────────────────────

        if success {
            masterFlowVM?.masterNotesBalance += pack.notes
            purchaseState = .success(pack.notes)
            try? await Task.sleep(for: .seconds(3))
        } else {
            purchaseState = .failure
            try? await Task.sleep(for: .seconds(2))
        }
        purchaseState = .idle
    }
}
