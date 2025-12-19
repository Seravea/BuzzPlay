//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    var colums = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Bindable var ambiantaudioPlayerVM: AmbiantSoundViewModel
    
    @Bindable var blindTestVM: BlindTestMasterViewModel
    @State var searchPlaylistText: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            
            //            AmbiantSoundsPadView(ambiantAudioPlayerVM: ambiantaudioPlayerVM, blindTestVM: blindTestVM)
            VStack {
                HStack {
                    TextField("Chercher une playlist", text: $searchPlaylistText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button {
                        withAnimation {
                            blindTestVM.playlists = []
                        }
                        Task {
                            await blindTestVM.search(query: searchPlaylistText)
                        }
                    }label: {
                        Text("Chercher")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if blindTestVM.allSongs.isEmpty {
                    ScrollView {
                        ForEach(blindTestVM.playlists) { playlist in
                            if blindTestVM.playlists.isEmpty {
                                ProgressView()
                            } else {
                                Button {
                                    
                                    Task {
                                        await blindTestVM.selectPlaylist(playlist)
                                    }
                                    
                                } label: {
                                    PlaylistCard(playlist: playlist)
                                }
                                .buttonBorderShape(.roundedRectangle)
                                
                            }
                        }
                    }
                } else {
                    ScrollView {
                        
                        
                        
                        ForEach(blindTestVM.allSongs) { song in
                            
                            
                            Button {
                                blindTestVM.selectedMusic = song
                            } label: {
                                SongCard(song: song, selectedSong: blindTestVM.selectedMusic)
                            }
                            
                        }
                    }
                    
                    
                }
            }
            if blindTestVM.playlists.isEmpty || blindTestVM.allSongs.isEmpty {
                Spacer()
            }
            
            
            if let song = blindTestVM.selectedMusic {
                songDataToShow(song: song)
            } else {
                VStack(alignment: .leading) {
                    Text("Selectionne une Musique pour la jouer")
                    Text("song.artist")
                        .foregroundStyle(.clear)
                }
                .font(.poppins(.body))
                .frame(maxWidth: .infinity)
            }
            
            //MARK: Music Play/Pause from Master
            VStack {
                PrimaryButtonView(title: "Lecture", action: {
                    
                    blindTestVM.startRound()
                    
                }, style: .filled(color: .darkestPurple), fontSize: Typography.body)
                // .disabled(ambiantaudioPlayerVM.isPlaying)
                
            }
            
            //MARK: Correct answer or Wrong answer
            VStack {
                HStack {
                    PrimaryButtonView(title: "Valider la réponse", action: {
                        blindTestVM.validateAnswer()
                    }, style: .filled(color: .green), fontSize: Typography.body)
                    
                    
                    PrimaryButtonView(title: "Refuser la réponse", action: {
                        blindTestVM.rejectAnswer()
                    }, style: .filled(color: .red), fontSize: Typography.body)
                    
                }
                
            }
            
            .onAppear {
                blindTestVM.appleMusicService.setupAudioSession()
                
                Task {
                    await blindTestVM.appleMusicService.setupAppleMusic()
                }
            }
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(ambiantaudioPlayerVM: AmbiantSoundViewModel(), blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
}
