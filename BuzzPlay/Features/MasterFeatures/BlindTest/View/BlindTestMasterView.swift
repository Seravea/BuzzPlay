//
//  BlindTestMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct BlindTestMasterView: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                
                //MARK: View for the Master ONLY (PRIVATE)
                PrivateMasterBlindTestView()
                    .frame(width: geo.size.width/2)
                    .padding()
                Rectangle()
                    .frame(width: geo.size.width/200)
                    .ignoresSafeArea()
                
                //MARK: View for shareScreen PUBLIC
                PublicMasterBlindTestView()
                    .frame(width: geo.size.width/2)
                    .padding()
            }
        }
    }
}

#Preview {
    BlindTestMasterView()
}
