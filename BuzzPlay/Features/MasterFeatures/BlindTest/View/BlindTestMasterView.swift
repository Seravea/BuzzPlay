//
//  BlindTestMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BlindTestMasterView: View {
    @Bindable var blindTestViewModel: BlindTestViewModel
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                
                //MARK: View for the Master ONLY (PRIVATE)
                PrivateMasterBlindTestView(blindTestVM: blindTestViewModel)
                    .frame(width: geo.size.width/2)
                    .padding()
                Rectangle()
                    .frame(width: geo.size.width/200)
//                    .ignoresSafeArea()
                
                //MARK: View for shareScreen PUBLIC
                PublicMasterBlindTestView(blindTestVM: blindTestViewModel)
//                    .frame(width: geo.size.width/2)
                    .padding()
//                    .padding(.trailing, -0)
            }
            
        }
//        .padding(10)
    }
}

#Preview {
    BlindTestMasterView(blindTestViewModel: BlindTestViewModel(gameVM: MasterFlowViewModel()))
}
