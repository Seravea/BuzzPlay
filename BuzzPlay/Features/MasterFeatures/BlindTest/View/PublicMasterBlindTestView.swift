//
//  PublicMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct PublicMasterBlindTestView: View {
    var body: some View {
        VStack {
            Text("Question 1 / 20")
                .font(.poppins(.largeTitle))
            
            ProgressView(value: 0.1)
                .progressViewStyle(.linear)
            
            
            VStack {
                Image(systemName: "stop")
            }
                
        }
        .frame(maxWidth: .infinity)
        .appDefaultTextStyle(Typography.body)
        
    }
}

#Preview {
    PublicMasterBlindTestView()
      
}
