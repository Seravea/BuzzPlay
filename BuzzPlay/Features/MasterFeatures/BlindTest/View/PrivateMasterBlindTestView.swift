//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    
    var column: [GridItem] = [GridItem(.flexible(minimum: 0)), GridItem(.flexible(minimum: 0))]
        @StateObject var audioPlayerVM = AmbiantSoundViewModel()
    
    var body: some View {
        VStack {
            LazyVGrid(columns: column, spacing: 20) {
                ForEach(audioPlayerVM.songs, id: \.self) { song in
                   
                    ButtonAmbiantSong(action: {
                        audioPlayerVM.playSound(song: song)
                    }, song: song)
                    
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
                    Text("Titre de la chanson")
                    Text("Nom Artiste/Groupe")
                    Text("Année de sortie")
                }
                .font(.poppins(.largeTitle))
                .frame(maxWidth: .infinity)
                
                PrimaryButtonView(title: "Play", action: {
                    
                }, style: .filled(color: .darkestPurple), fontSize: .largeTitle)
//                .frame(width: 120)
            }
            
            HStack {
                PrimaryButtonView(title: "Valider", action: {
                    
                }, style: .filled(color: .green), fontSize: .largeTitle)
                
                PrimaryButtonView(title: "Refuser", action: {
                    
                }, style: .filled(color: .red), fontSize: .largeTitle)
            }
           
                
        }
    }
}

#Preview {
    PrivateMasterBlindTestView()
}
