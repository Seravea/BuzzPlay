//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation


@Observable
class TeamViewModel: ObservableObject {
    
    var team: Team
    
    init(team: Team) {
        self.team = team
    }
}
