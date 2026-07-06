//
//  AmbiantSoundsPadView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import SwiftUI


struct AmbiantSoundsPadView: View {
    @Bindable var ambiantAudioPlayerVM: AmbiantSoundViewModel
    @Bindable var blindTestVM: BlindTestMasterViewModel
    
    var column: [GridItem] = [GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0))]
    var body: some View {
        
        LazyVGrid(columns: column, spacing: BuzzSpacing.xl) {
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
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
                .foregroundStyle(Color.darkPink)
        }
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        AmbiantSoundsPadView(
            ambiantAudioPlayerVM: AmbiantSoundViewModel(),
            blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel())
        )
        .padding()
    }
}
