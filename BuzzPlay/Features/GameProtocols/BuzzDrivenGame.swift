//
//  BuzzDrivenGame.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation


protocol BuzzDrivenGame: AnyObject {
    // Appelé par le Master quand une équipe a buzzé
    func handleBuzz(from team: Team)
}
