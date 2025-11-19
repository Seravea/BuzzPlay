//
//  CoinsViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation





@Observable
class CoinsViewModel {
    
    let moneyCanSend: [Int] = [10, 20, 50, 100]
    var selectedMoney: Int?
    var isSendingOpen: Bool = false
    var masterFlowViewModel: MasterFlowViewModel?
    var teamFlowViewModel: TeamFlowViewModel?
    
    var errorMessage: String?
    
    var onBuyGift: ((Team, Gift) -> Void)?
    
    init(masterFlowVM: MasterFlowViewModel) {
        self.masterFlowViewModel = masterFlowVM
        self.teamFlowViewModel = nil
    }
    
    init(teamFlowVM: TeamFlowViewModel) {
        self.masterFlowViewModel = nil
        self.teamFlowViewModel = teamFlowVM
    }
   
    
    var isMaster: Bool {
        masterFlowViewModel != nil
    }
    
    
    

}



//Gift enum / actions
extension CoinsViewModel {
    enum Gift: Codable, Hashable, CaseIterable {
        ///Actions
        case scoreDoubled
        case enemyCanNotBuzz
        case showIndicies
        ///Skins
        case changeBuzzColor
        case changeBuzzSound
        
        var title: String {
            switch self {
                case .scoreDoubled:
                return "Doubler le score"
            case .enemyCanNotBuzz:
                return "Empêcher l'adversaire de buzzer"
            case .showIndicies:
                return "Montrer les indices"
            case .changeBuzzColor:
                    //Peut être troller avec "Super Cadeau"
                return "Changer la couleur du buzz"
            case .changeBuzzSound:
                    //Pareil ici
                return "Changer le son du buzz"
            }
        }
        
        var price: Int {
            switch self {
            case .scoreDoubled:
                return 30
            case .enemyCanNotBuzz:
                return 50
            case .showIndicies:
                return 50
            case .changeBuzzColor:
                return 20
            case .changeBuzzSound:
                return 20
            }
        }
        
        var giftAction: () -> Void {
            switch self {
            case .scoreDoubled:
                return {}
            case .enemyCanNotBuzz:
                return {}
            case .showIndicies:
                return {}
            case .changeBuzzColor:
                return {}
            case .changeBuzzSound:
                return {}
            }
        }
    }
    
    func buyGift(_ gift: Gift) {
        guard let team = teamFlowViewModel?.team else {
            errorMessage = "Pas de team trouvé"
            return
        }
        guard team.accountAmount >= gift.price else {
            errorMessage = "Tu n'as pas assez d'argent"
            return
        }
        
        onBuyGift?(team, gift)
    }
    
}
