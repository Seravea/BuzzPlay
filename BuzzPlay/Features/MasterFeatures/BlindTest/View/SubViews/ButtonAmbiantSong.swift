//
//  ButtonAmbiantSong.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct ButtonAmbiantSong: View {
    var action: () -> Void
    var song: String
    var body: some View {
        Button {
            action()
        } label: {
            Text(song)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    Capsule()
                        .foregroundStyle(Color.darkestPurple)
                    
                }
            
        }
    }
}

#Preview {
    ButtonAmbiantSong(action: { }, song: "BeginQuestion")
}
