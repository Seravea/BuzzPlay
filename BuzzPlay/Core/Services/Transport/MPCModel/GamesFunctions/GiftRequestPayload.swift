//
//  GiftRequestPayload.swift
//  BuzzPlay
//

import Foundation

struct GiftRequestPayload: Codable {
    let gift: CoinsViewModel.Gift
    let targetPlayerID: UUID?   // non-nil uniquement pour enemyCanNotBuzz (1 joueur ciblé)
    let buyerID: UUID           // pour allEnemiesCanNotBuzz (ne pas bloquer l'acheteur)
    let selectedSound: String?  // son choisi par le Player pour changeBuzzSound
}
