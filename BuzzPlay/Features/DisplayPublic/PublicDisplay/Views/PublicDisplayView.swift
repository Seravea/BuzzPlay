//
//  PublicDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicDisplayView: View {
    //TODO: finish TeamGameVM and PublicDisplayVM
    var buzzLockPayload: BuzzLockPayload?
    var publicState: PublicState
    
    var body: some View {
        VStack {
            
            switch publicState {
                
            case .waiting:
                ProgressView()
            case .quiz(let state):
                PublicQuizDisplayView(state: state)
            }
            
        }
        
    }
}

#Preview {
    PublicDisplayView(publicState: PublicState.waiting)
}
