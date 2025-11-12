//
//  BlindTestMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BlindTestMasterView: View {
    var body: some View {
       HStack {
           
           //MARK: View for the Master ONLY (PRIVATE)
           PrivateMasterBlindTestView()
           
           Rectangle()
               .frame(width: 10)
               .ignoresSafeArea()
           
           //MARK: View for shareScreen PUBLIC
           PublicMasterBlindTestView()
        }
    }
}

#Preview {
    BlindTestMasterView()
}
