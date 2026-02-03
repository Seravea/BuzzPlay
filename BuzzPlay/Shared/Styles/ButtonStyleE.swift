//
//  LinearGradUIColorE.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 21/01/2026.
//

import Foundation
import SwiftUI

enum ButtonStyleE {
    case destructive, neutral, positive, secondary
    
    var linearGradient: LinearGradient {
        switch self {
            case .destructive:
            return LinearGradient(colors: [.redLeading, .redTrailing], startPoint: .leading, endPoint: .trailing)
            case .positive:
            return LinearGradient(colors: [.greenLeading, .greenTrailing], startPoint: .leading, endPoint: .trailing)
            case .neutral:
            return LinearGradient(colors: [.purpleLeading, .purpleTrailing], startPoint: .leading, endPoint: .trailing)
            case .secondary:
            return LinearGradient(colors: [.yellowLeading, .yellowTrailing], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    
}
