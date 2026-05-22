//
//  CoinsViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
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

    var onBuyGift: ((Player, Gift) -> Void)?

    init(masterFlowVM: MasterFlowViewModel) {
        self.masterFlowViewModel = masterFlowVM
        self.playerGameViewModel = nil
        self.mpcService = masterFlowVM.mpcService
    }

    init(playerGameVM: PlayerGameViewModel) {
        self.masterFlowViewModel = nil
        self.playerGameViewModel = playerGameVM
        self.mpcService = playerGameVM.mpc
        setupPlayerCallbacks()
    }

    var isMaster: Bool { masterFlowViewModel != nil }

    var otherPlayers: [Player] {
        guard let pgVM = playerGameViewModel else { return [] }
        return pgVM.knownPlayers.filter { $0.id != pgVM.player.id }
    }

    private func setupPlayerCallbacks() {
        onBuyGift = { [weak self] player, gift in
            guard let self else { return }
            let payload = GiftRequestPayload(gift: gift, targetPlayerID: nil, buyerID: player.id)
            self.mpcService?.sendMessage(.buyGiftRequest(payload))
        }
    }

    func sendGiftRequest(_ gift: CoinsViewModel.Gift, targeting targetPlayer: Player?) {
        guard let player = playerGameViewModel?.player else { return }
        let payload = GiftRequestPayload(
            gift: gift,
            targetPlayerID: targetPlayer?.id,
            buyerID: player.id
        )
        mpcService?.sendMessage(.buyGiftRequest(payload))
    }
    
    
    

}



//Gift enum / actions
extension CoinsViewModel {
    enum Gift: Codable, Hashable, CaseIterable {
        // Actions
        case scoreDoubled           // 30 coins — 2x points prochaine bonne réponse
        case enemyCanNotBuzz        // 50 coins — bloque 1 joueur choisi (1 manche)
        case allEnemiesCanNotBuzz   // 100 coins — bloque TOUS les adversaires (1 manche)
        case showIndicies           // 50 coins — indice sur la chanson/question
        // Skins
        case changeBuzzColor        // 20 coins — couleur random surprise 🎨
        case changeBuzzSound        // 20 coins — son ambiant aléatoire 🔊

        var title: String {
            switch self {
            case .scoreDoubled:         return "Doubler le score"
            case .enemyCanNotBuzz:      return "Bloquer un adversaire"
            case .allEnemiesCanNotBuzz: return "Bloquer TOUT le monde"
            case .showIndicies:         return "Afficher un indice"
            case .changeBuzzColor:      return "Super Cadeau 🎁"
            case .changeBuzzSound:      return "Changer le son du buzz"
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
            }
        }

        // Indique si ce cadeau nécessite de choisir un joueur cible
        var requiresTargetPlayer: Bool {
            self == .enemyCanNotBuzz
        }
    }
    
    func buyGift(_ gift: Gift, targeting targetPlayer: Player? = nil) {
        guard let player = playerGameViewModel?.player else {
            errorMessage = "Pas de joueur trouvé"
            return
        }
        guard player.accountAmount >= gift.price else {
            errorMessage = "Tu n'as pas assez d'argent"
            return
        }

        if gift.requiresTargetPlayer {
            guard let target = targetPlayer else {
                errorMessage = "Choisir un adversaire d'abord"
                return
            }
            sendGiftRequest(gift, targeting: target)
        } else {
            sendGiftRequest(gift, targeting: nil)
        }
        errorMessage = nil
    }

    func sendCoinsToPlayer(_ player: Player, amount: Int) {
        guard let masterVM = masterFlowViewModel else {
            errorMessage = "Pas de Maître"
            return
        }

        masterVM.addCoinsToPlayer(player, amount: amount)
        errorMessage = nil
    }

}
