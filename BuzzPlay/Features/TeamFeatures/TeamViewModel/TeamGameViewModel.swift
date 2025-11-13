//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation




@Observable
final class TeamGameViewModel: ObservableObject {
    
    var team: Team
    
    private let mpc: MPCService
    
    
    var receivedMessage: String = ""
    
    var routePath: [Route] = []
    
    
    init(team: Team, mpc: MPCService) {
        self.team = team
        self.mpc = mpc
//        setupMPC()
    }
   

//        func makeBuzzViewModel() -> BuzzViewModel {
//            BuzzViewModel(team: team, parent: self)
//        }
    
}
