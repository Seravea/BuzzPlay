//
//  PublicDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicDisplayView: View {
    @State var publicDisplayVM = PublicDisplayViewModel()
   
    var body: some View {
    
        switch publicDisplayVM.state {
        case .waiting:
            ProgressView()
        case .quiz(let state):
            PublicQuizDisplayView(state: state)
        }
    
    }
}

#Preview {
    PublicDisplayView()
}
