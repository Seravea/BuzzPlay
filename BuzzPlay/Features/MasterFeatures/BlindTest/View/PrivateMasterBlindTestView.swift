//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    
    var column: [GridItem] = [GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0))]
    @StateObject var ambiantaudioPlayerVM = AmbiantSoundViewModel()

    @ObservedObject var blindTestVM: BlindTestViewModel

    var body: some View {
        VStack {
            LazyVGrid(columns: column, spacing: 20) {
                ForEach(ambiantaudioPlayerVM.songs, id: \.self) { song in
                   
                    ButtonAmbiantSong(action: {
                        ambiantaudioPlayerVM.playSound(song: song)
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
            
            HStack {
                VStack(alignment: .leading) {
                    Text(blindTestVM.songs[blindTestVM.nowPlayingSongIndex].title)
                    Text(blindTestVM.songs[blindTestVM.nowPlayingSongIndex].artist)
                    Text(blindTestVM.songs[blindTestVM.nowPlayingSongIndex].creationYear)
                }
                
                .font(.poppins(.largeTitle))
                .frame(maxWidth: .infinity)
                
                
                //MARK: Music PLAy/STOP from Master
                VStack {
                    PrimaryButtonView(title: "Play", action: {
                    
                        blindTestVM.playSound()
                    }, style: .filled(color: .darkestPurple), fontSize: .largeTitle)
                   // .disabled(ambiantaudioPlayerVM.isPlaying)
                    PrimaryButtonView(title: "Pause", action: {
                        blindTestVM.pauseSong()
                    }, style: .outlined(color: .darkestPurple), fontSize: .largeTitle)
                }
//                .frame(width: 120)
            }
            
            
            //MARK:
            HStack {
                PrimaryButtonView(title: "Valider", action: {
                    blindTestVM.isCorrect = true
                    blindTestVM.nextSong()
                }, style: .filled(color: .green), fontSize: .largeTitle)
                
                
                PrimaryButtonView(title: "Refuser", action: {
                    blindTestVM.isCorrect = false
                    blindTestVM.playSound()
                }, style: .filled(color: .red), fontSize: .largeTitle)
                
            }
           
                
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(blindTestVM: BlindTestViewModel())
}
