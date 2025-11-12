//
//  PublicMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct PublicMasterBlindTestView: View {
    @State var isPlayingSong: Bool = false
    var body: some View {
        VStack {
            Text("Question 1 / 20")
                .font(.poppins(.largeTitle))
            
            ProgressView(value: 0.1)
                .progressViewStyle(.linear)
            
            
           
                
                Image(systemName: isPlayingSong == true ? "play.circle.fill" : "stop.circle.fill")
                    .font(.system(size: 150))
                    .padding(.leading)
                    .foregroundStyle(Color.darkPink)
                    .symbolEffectsRemoved(!isPlayingSong)
                    .symbolEffect(.bounce)
                    
            
            
                
        }
        .frame(maxWidth: .infinity)
        .appDefaultTextStyle(Typography.body)
        
    }
}

#Preview {
    PublicMasterBlindTestView()
      
}
