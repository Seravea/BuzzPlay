//
//  PlayerNotesWallet.swift
//  BuzzPlay
//
//  #v1-economy — porte-monnaie LOCAL du joueur. Les Notes se gagnent en jouant
//  (connexion quotidienne, fin de partie) et se dépensent sur CE téléphone uniquement.
//  Aucun transfert entre appareils (guideline 3.1.1 — pas de gifting d'achats),
//  aucun achat de Notes en V1 (réservé V2, sur l'Apple ID du joueur).
//

import Foundation

@MainActor
@Observable
final class PlayerNotesWallet {

    static let shared = PlayerNotesWallet()

    private static let balanceKey        = "buzzplay.player.notesBalance"
    private static let lastDailyClaimKey = "buzzplay.player.lastDailyClaimDate"
    private static let welcomeClaimedKey = "buzzplay.player.welcomeBonusClaimed"
    private static let welcomeAmount     = 100    // bonus de bienvenue, première ouverture
    private static let dailyAmount       = 50
    private static let dailyMaxDays      = 7      // cumul plafonné si on n'ouvre pas l'app tous les jours
    private static let endOfGameAmount   = 100

    /// Crédit fraîchement reçu, à afficher en toast par l'UI (remis à nil par la vue).
    var pendingCreditToast: Int?

    private(set) var balance: Int = {
        UserDefaults.standard.integer(forKey: balanceKey)
    }() {
        didSet { UserDefaults.standard.set(balance, forKey: Self.balanceKey) }
    }

    // MARK: - Gains

    /// +50 Notes par jour de connexion (cumul plafonné à 7 jours), crédités automatiquement
    /// à l'entrée du flux Player — pas de bouton à presser.
    /// Première ouverture : +100 de bienvenue en plus (toast cumulé « +150 »).
    func claimDailyIfNeeded() {
        let ud = UserDefaults.standard
        if !ud.bool(forKey: Self.welcomeClaimedKey) {
            credit(Self.welcomeAmount)
            ud.set(true, forKey: Self.welcomeClaimedKey)
        }
        let days: Int
        if let last = ud.object(forKey: Self.lastDailyClaimKey) as? Date {
            let cal = Calendar.current
            let elapsed = cal.dateComponents([.day],
                                             from: cal.startOfDay(for: last),
                                             to: cal.startOfDay(for: Date())).day ?? 0
            days = min(max(elapsed, 0), Self.dailyMaxDays)
        } else {
            days = 1   // première ouverture
        }
        guard days > 0 else { return }
        credit(days * Self.dailyAmount)
        ud.set(Date(), forKey: Self.lastDailyClaimKey)
    }

    /// +100 Notes à la fin d'une partie complète (sur masterGameComplete, une fois par partie).
    func creditEndOfGame() {
        credit(Self.endOfGameAmount)
    }

    // MARK: - Dépense

    /// Débite le solde local. false si solde insuffisant (rien n'est débité).
    @discardableResult
    func spend(_ amount: Int) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }

    private func credit(_ amount: Int) {
        balance += amount
        pendingCreditToast = (pendingCreditToast ?? 0) + amount
    }
}
