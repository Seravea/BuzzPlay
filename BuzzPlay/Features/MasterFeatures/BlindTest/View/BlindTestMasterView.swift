//
//  BlindTestMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BlindTestMasterView: View {
    @Bindable var blindTestViewModel: BlindTestMasterViewModel
    @Bindable var ambiantSoundViewModel = AmbiantSoundViewModel()
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                
                //MARK: View for the Master ONLY (PRIVATE)
                PrivateMasterBlindTestView(ambiantaudioPlayerVM: ambiantSoundViewModel, blindTestVM: blindTestViewModel)
//                    .frame(width: geo.size.width/2)
                    .padding()
                
                ///separator
//                Rectangle()
//                    .frame(width: geo.size.width/200)
//                
//                //MARK: View for shareScreen PUBLIC
//                PublicMasterBlindTestView(blindTestVM: blindTestViewModel)
//                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                BackgroundAppView()
            )
        }
    }
}

#Preview {
    BlindTestMasterView(blindTestViewModel: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
}
