//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI
import AVFoundation


struct PrivateMasterBlindTestView: View {
    var column: [GridItem] = [GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0))]
        
    
    var body: some View {
        VStack {
            LazyVGrid(columns: column, spacing: 20) {
                ForEach(0..<10) { i in
                    PrimaryButtonView(title: "songTitle", action: {
                        //PLAY SONG
                    }, style: .filled, fontSize: .title)
                }
            }
            .frame(width: 350)
            .padding()
            .background {
               RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.purple)
            }
                
        }
    }
}

#Preview {
    PrivateMasterBlindTestView()
}
