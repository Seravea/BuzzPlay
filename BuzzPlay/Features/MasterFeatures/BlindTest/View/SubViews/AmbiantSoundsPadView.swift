//
//  AmbiantSoundsPadView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import SwiftUI


struct AmbiantSoundsPadView: View {
    var ambiantAudioPlayerVM: AmbiantSoundViewModel
    var blindTestVM: BlindTestViewModel
    
    var column: [GridItem] = [GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0))]
    var body: some View {
        
        LazyVGrid(columns: column, spacing: 20) {
            ForEach(ambiantAudioPlayerVM.songs, id: \.self) { song in
                
                ButtonAmbiantSong(action: {
                    ambiantAudioPlayerVM.playSound(song: song)
                }, song: song)
                .disabled(blindTestVM.isPlaying)
            }
        }
        //            .frame(width: 350)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.darkPink)
        }
    }
}
