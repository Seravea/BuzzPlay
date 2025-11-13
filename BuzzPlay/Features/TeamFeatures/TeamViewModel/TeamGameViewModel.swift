//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation


@MainActor
@Observable
final class TeamGameViewModel: ObservableObject {
    
    var team: Team
    
    private let mpc: MPCService
    
    
    var receivedMessage: String = ""
    
    
    init(team: Team, mpc: MPCService) {
        self.team = team
        self.mpc = mpc
        //setupMPC()
    }
   
    
    
}
