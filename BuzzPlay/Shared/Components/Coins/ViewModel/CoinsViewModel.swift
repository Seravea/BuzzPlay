//
//  CoinsViewModel.swift
//  BuzzPlay
//

import Foundation

@MainActor
@Observable
class CoinsViewModel {

    var masterFlowViewModel: MasterFlowViewModel?
    weak var playerGameViewModel: PlayerGameViewModel?
    let mpcService: MPCService?

    var errorMessage: String?
    /// Empêche le double-tap sur un gift pendant l'aller-retour MPC
    var isPendingPurchase: Bool = false

    init(masterFlowVM: MasterFlowViewModel) {
        self.masterFlowViewModel = masterFlowVM
        self.playerGameViewModel = nil
        self.mpcService = masterFlowVM.mpcService
    }

    init(playerGameVM: PlayerGameViewModel) {
        self.masterFlowViewModel = nil
        self.playerGameViewModel = playerGameVM
        self.mpcService = playerGameVM.mpc
    }

    var isMaster: Bool { masterFlowViewModel != nil }

    var otherPlayers: [Player] {
        guard let pgVM = playerGameViewModel else { return [] }
        return pgVM.knownPlayers.filter { $0.id != pgVM.player.id }
    }

    private func setError(_ message: String) {
        errorMessage = message
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            self?.errorMessage = nil
        }
    }

    func sendGiftRequest(_ gift: CoinsViewModel.Gift, targeting targetPlayer: Player?, selectedSound: String? = nil) {
        guard let player = playerGameViewModel?.player else { return }
        let payload = GiftRequestPayload(
            gift: gift,
            targetPlayerID: targetPlayer?.id,
            buyerID: player.id,
            selectedSound: selectedSound
        )
        mpcService?.sendMessage(.buyGiftRequest(payload))
    }

}

//Gift enum / actions
extension CoinsViewModel {
    enum Gift: Codable, Hashable, CaseIterable {
        case scoreDoubled
        case enemyCanNotBuzz
        case allEnemiesCanNotBuzz
        case showIndicies
        case changeBuzzColor
        case changeBuzzSound
        case shieldSingle
        case shieldAll

        var title: String {
            switch self {
            case .scoreDoubled:         return "Doubler le score"
            case .enemyCanNotBuzz:      return "Bloquer un adversaire"
            case .allEnemiesCanNotBuzz: return "Bloquer TOUT le monde"
            case .showIndicies:         return "Afficher un indice"
            case .changeBuzzColor:      return "Super Cadeau 🎁"
            case .changeBuzzSound:      return "Changer le son du buzz"
            case .shieldSingle:         return "Bouclier individuel"
            case .shieldAll:            return "Bouclier global"
            }
        }

        var price: Int {
            switch self {
            case .scoreDoubled:         return 30
            case .enemyCanNotBuzz:      return 50
            case .allEnemiesCanNotBuzz: return 100
            case .showIndicies:         return 50
            case .changeBuzzColor:      return 20
            case .changeBuzzSound:      return 20
            case .shieldSingle:         return 30
            case .shieldAll:            return 60
            }
        }

        var requiresTargetPlayer: Bool {
            self == .enemyCanNotBuzz
        }

        /// Nombre minimum d'autres joueurs pour que ce pouvoir soit utilisable
        var minimumOtherPlayers: Int {
            switch self {
            case .allEnemiesCanNotBuzz, .shieldAll: return 2
            case .enemyCanNotBuzz, .shieldSingle:   return 1
            default:                                return 0
            }
        }
    }
    
    func buyGift(_ gift: Gift, targeting targetPlayer: Player? = nil, selectedSound: String? = nil) {
        guard !isPendingPurchase else { return }
        guard playerGameViewModel?.player != nil else {
            setError("Pas de joueur trouvé")
            return
        }
        // #v1-economy — le solde vit en LOCAL sur ce téléphone (PlayerNotesWallet) :
        // vérification + débit ici, le Master ne fait qu'appliquer l'effet du cadeau.
        guard PlayerNotesWallet.shared.balance >= gift.price else {
            setError("Pas assez de Notes 🎵 — joue pour en gagner !")
            return
        }

        var target: Player? = nil
        if gift.requiresTargetPlayer {
            guard let chosen = targetPlayer else {
                setError("Choisir un adversaire d'abord")
                return
            }
            target = chosen
        }

        PlayerNotesWallet.shared.spend(gift.price)
        sendGiftRequest(gift, targeting: target, selectedSound: selectedSound)
        isPendingPurchase = true
        errorMessage = nil
        // Failsafe : reset si le Master ne répond pas dans les 5s
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(5))
            self?.isPendingPurchase = false
        }
    }

    /// Appelé quand buyGiftResult arrive du Master — débloque le shop
    func onGiftConfirmed() {
        isPendingPurchase = false
    }
}
