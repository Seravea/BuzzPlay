//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation




@Observable
final class TeamGameViewModel{
    
    var gameVM: TeamFlowViewModel
    var team: Team
    
    
    var receivedMessage: String = ""
    
    init(gameVM: TeamFlowViewModel) {
        self.gameVM = gameVM
        if let team = gameVM.team {
            self.team = team
        }else {
            self.team = Team(name: "ERREUR", colorIndex: 0)
        }
        
        self.gameVM.mpc.startBrowsing()

//        setupMPC()
    }
   

//        func makeBuzzViewModel() -> BuzzViewModel {
//            BuzzViewModel(team: team, parent: self)
//        }
    
}
