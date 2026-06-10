//
//  CoinsViewModel.swift
//  BuzzPlay
//

import Foundation

@MainActor
@Observable
class CoinsViewModel {

    let moneyCanSend: [Int] = [10, 20, 50, 100]
    var selectedMoney: Int?
    var isSendingOpen: Bool = false
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
        guard let player = playerGameViewModel?.player else {
            setError("Pas de joueur trouvé")
            return
        }
        guard player.accountAmount >= gift.price else {
            setError("Pas assez de Notes 🎵 — demande au Maître")
            return
        }

        if gift.requiresTargetPlayer {
            guard let target = targetPlayer else {
                setError("Choisir un adversaire d'abord")
                return
            }
            sendGiftRequest(gift, targeting: target, selectedSound: selectedSound)
        } else {
            sendGiftRequest(gift, targeting: nil, selectedSound: selectedSound)
        }
        isPendingPurchase = true
        errorMessage = nil
        // Failsafe : reset si le Master ne répond pas dans les 5s
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(5))
            self?.isPendingPurchase = false
        }
    }

    /// Appelé par PlayerGameViewModel quand updatedPlayer est reçu — débloque le shop
    func onPlayerUpdated(_ updatedPlayer: Player) {
        isPendingPurchase = false
    }

    func sendCoinsToPlayer(_ player: Player, amount: Int) {
        guard let masterVM = masterFlowViewModel else {
            errorMessage = "Pas de Maître"
            return
        }
        // #3 — l'envoi individuel est payant : il décompte le solde du Master
        // (la déduction est ici et PAS dans addCoinsToPlayer, sinon distributeToAll
        // double-déduirait — il décompte déjà amount × nb joueurs de son côté).
        guard masterVM.masterNotesBalance >= amount else {
            errorMessage = "Solde insuffisant"
            return
        }
        masterVM.addCoinsToPlayer(player, amount: amount)
        masterVM.masterNotesBalance -= amount
        errorMessage = nil
    }

    func distributeToAll(_ amount: Int) {
        guard let masterVM = masterFlowViewModel else {
            errorMessage = "Pas de Maître"
            return
        }
        
        guard masterVM.masterNotesBalance >= amount * masterVM.players.count else {
            errorMessage = "Pas assez de notes pour tous"
            return
        }

        for player in masterVM.players {
            masterVM.addCoinsToPlayer(player, amount: amount)
        }
        masterVM.masterNotesBalance -= amount * masterVM.players.count
        errorMessage = nil
    }

}
