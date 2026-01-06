//
//  MPCError.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 25/11/2025.
//

import Foundation


enum MPCError: LocalizedError {
    case decodingFailed(underlying: Error?)
    case encodingFailed(underlying: Error?)
    case invalidPeerID
    case notConnectedPeers
    case sessionNotReady
    case roleMisMatch(expected: MPCRole, actual: MPCRole?)
    case sendFailed(underlying: Error?)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "Impossible de décoder le message reçus"
        case .encodingFailed:
            return "Impossible de coder le message à envoyer"
        case .invalidPeerID:
            return "Paramètre peerID invalide"
            case .notConnectedPeers:
            return "Aucun Peed connécté, envoi impossible"
        case .sessionNotReady:
            return "La session MPC n'est pas prête"
        case .roleMisMatch(expected: let expected, actual: let actual):
            return "Le rôle attendu est \(expected), actuel : \(String(describing: actual))"
        case .sendFailed:
            return "Échec lors de l'envoi du message"
        }
    }

    
}
