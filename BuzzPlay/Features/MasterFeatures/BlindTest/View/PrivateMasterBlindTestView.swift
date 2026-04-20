//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    //    var colums = [
    //        GridItem(.flexible()),
    //        GridItem(.flexible()),
    //        GridItem(.flexible()),
    //    ]
    //    var playlistColums = [
    //        GridItem(.flexible()),
    //        GridItem(.flexible()),
    //    ]
    @Namespace private var songNamespace
    @FocusState private var searchTextFieldFocused: Bool
    @Bindable var ambiantaudioPlayerVM: AmbiantSoundViewModel
    
    @Bindable var blindTestVM: BlindTestMasterViewModel
    @State var searchPlaylistText: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            
            //            AmbiantSoundsPadView(ambiantAudioPlayerVM: ambiantaudioPlayerVM, blindTestVM: blindTestVM)
            
            //            VStack {
            HStack {
                TextFieldCustom(text: $searchPlaylistText, prompt: "Chercher une playlist", textSize: .body)
                    .focused($searchTextFieldFocused)
                
                PrimaryButtonView(title: "Chercher", action: {
                    withAnimation {
                        blindTestVM.playlists = []
                        blindTestVM.allSongs = []
                        searchTextFieldFocused = false
                    }
                    Task {
                        await blindTestVM.search(query: searchPlaylistText)
                    }
                }, style: .filled(buttonStyle: .secondary), fontSize: Typography.body)
                .frame(maxWidth: 150)
            }
            
            if blindTestVM.isFetching {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.3)
                    Spacer()
                }
                .padding(.vertical, 32)
            } else if blindTestVM.allSongs.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(blindTestVM.playlists) { playlist in
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
            } else if !blindTestVM.isGameActive && !blindTestVM.allSongs.isEmpty {
                
                VStack {
                    ScrollView {
                        ForEach(blindTestVM.allSongs) { song in
                            
                            Button {
                                withAnimation {
                                    blindTestVM.selectedMusic = song
                                }
                            } label: {
                                SongCard(song: song, selectedSong: blindTestVM.selectedMusic/*, canPlayFullTrack: blindTestVM.canPlayCatalogContent*/)
                            }
                            .matchedGeometryEffect(id: "song\(song.id)", in: songNamespace)
                            

                        }
                    }
                }
            }
            
            
            
            //                    .padding(.bottom, 4)
            if blindTestVM.allSongs.isEmpty && !blindTestVM.isFetching {
                Spacer()
            }
           
                if blindTestVM.isGameActive {
                    VStack {
                    if let selectedMusic = blindTestVM.selectedMusic {
                        SongCard(song: blindTestVM.selectedMusic, isPlaying: blindTestVM.isPlaying)
                            .matchedGeometryEffect(id: "song\(selectedMusic.id)", in: songNamespace)
                    }
                    
                    
                    
                    
                    if let teamWining = blindTestVM.teamHasBuzz {
                        
                        TeamCardView(team: teamWining, buzzTime: blindTestVM.formattedTime, showPoints: false)
                        
                    } else {
                        
                        TimerCardView(timer: blindTestVM.formattedTime, isCorrectAnswer: blindTestVM.isCorrect)
                        
                    }
                }
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            
            //MARK: Music Play/Pause from Master
            VStack {
                PrimaryButtonView(title: "Lecture", action: {
                    blindTestVM.startRound()
                }, style: .filled(buttonStyle: .neutral), fontSize: Typography.body)
                .disabled(blindTestVM.isPlaying || blindTestVM.isFetching)
                .opacity(blindTestVM.isPlaying || blindTestVM.isFetching ? 0.7 : 1)
                
                
                
                //MARK: Correct answer or Wrong answer
                VStack {
                    HStack {
                        PrimaryButtonView(title: "Valider la réponse", action: {
                            blindTestVM.validateAnswer(points: 10)
                        }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                        .disabled(blindTestVM.teamHasBuzz == nil)
                        .opacity(blindTestVM.teamHasBuzz == nil ? 0.7 : 1)
                        
                        
                        PrimaryButtonView(title: "Refuser la réponse", action: {
                            blindTestVM.rejectAnswer()
                        }, style: .filled(buttonStyle: .destructive), fontSize: Typography.body)
                        .disabled(blindTestVM.teamHasBuzz == nil)
                        .opacity(blindTestVM.teamHasBuzz == nil ? 0.7 : 1)
                    }
                    
                }
                .animation(.default, value: blindTestVM.teamHasBuzz)
                .animation(.default, value: blindTestVM.isPlaying)
                .animation(.default, value: blindTestVM.isFetching)
                
                .foregroundStyle(.white)
                
                
                .alert("Information", isPresented: $blindTestVM.showSubscriptionAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(blindTestVM.subscriptionAlertMessage)
                }
                .alert("Erreur", isPresented: Binding(
                    get: { blindTestVM.fetchError != nil },
                    set: { if !$0 { blindTestVM.fetchError = nil } }
                )) {
                    Button("OK", role: .cancel) { blindTestVM.fetchError = nil }
                } message: {
                    Text(blindTestVM.fetchError ?? "")
                }
                
                .onAppear {
                    blindTestVM.appleMusicService.setupAudioSession()
                    blindTestVM.observeSubscriptionUpdates()
                    Task {
                        await blindTestVM.appleMusicService.setupAppleMusic()
                        await blindTestVM.updateCatalogPlaybackCapability()
                    }
                }
            }
            
        }
        .animation(.default, value: blindTestVM.isGameActive)
        

        //        }
        
        
    }
}

#Preview {
    PrivateMasterBlindTestView(ambiantaudioPlayerVM: AmbiantSoundViewModel(), blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundAppView()
        )
}
