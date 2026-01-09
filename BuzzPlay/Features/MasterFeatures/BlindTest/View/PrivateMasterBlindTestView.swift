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

    @FocusState private var searchTextFieldFocused: Bool
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
                        .focused($searchTextFieldFocused)
                        .padding()
                    Button {
                        withAnimation {
                            blindTestVM.playlists = []
                            blindTestVM.allSongs = []
                            searchTextFieldFocused = false
                        }
                        Task {
                            await blindTestVM.search(query: searchPlaylistText)
                        }
                    }label: {
                        HStack {
                            Text("Chercher")

                            if blindTestVM.isFetching {
                                ProgressView()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(blindTestVM.isPlaying)
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
                                withAnimation {
                                    blindTestVM.selectedMusic = song
                                }
                            } label: {
                                SongCard(song: song, selectedSong: blindTestVM.selectedMusic, canPlayFullTrack: blindTestVM.canPlayCatalogContent)
                            }

                        }
                    }


                }
            }
            .padding(.bottom)

            if blindTestVM.playlists.isEmpty || blindTestVM.allSongs.isEmpty {
                Spacer()
            }


            if let song = blindTestVM.selectedMusic {
                SongCard(song: song, canPlayFullTrack: blindTestVM.canPlayCatalogContent)
            } else {
                HStack(alignment: .top) {
                        Text("")
                            .frame(width: 80, height: 80)

                    VStack(alignment: .leading) {
                        Text(blindTestVM.playlists.isEmpty ? "Selectionne une playlist à jouer" : "Selectionne une musique à jouer")
                            .font(.poppins(.headline))
                            .bold()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("i")
                            .font(.poppins(.body))
                            .foregroundStyle(.clear)
                        Text("i")
                            .foregroundStyle(.clear)
                    }
                }
                .frame(height: 80)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.gray.opacity(0.2))
                }

            }

            //MARK: Music Play/Pause from Master
            VStack {
                PrimaryButtonView(title: "Lecture", action: {
                    blindTestVM.startRound()

                }, style: .filled(color: .darkestPurple), fontSize: Typography.body)
                .disabled(blindTestVM.isPlaying)
                .opacity(blindTestVM.isPlaying ? 0.7 : 1)

            }

            //MARK: Correct answer or Wrong answer
            VStack {
                HStack {
                    PrimaryButtonView(title: "Valider la réponse", action: {
                        blindTestVM.validateAnswer(points: 10)
                    }, style: .filled(color: .green), fontSize: Typography.body)
                    .disabled(blindTestVM.teamHasBuzz == nil)
                    .opacity(blindTestVM.teamHasBuzz == nil ? 0.7 : 1)


                    PrimaryButtonView(title: "Refuser la réponse", action: {
                        blindTestVM.rejectAnswer()
                    }, style: .filled(color: .red), fontSize: Typography.body)
                    .disabled(blindTestVM.teamHasBuzz == nil)
                    .opacity(blindTestVM.teamHasBuzz == nil ? 0.7 : 1)
                }

            }
            .animation(.default, value: blindTestVM.teamHasBuzz)
            .animation(.default, value: blindTestVM.isPlaying)
            .animation(.default, value: blindTestVM.isFetching)

            .onAppear {
                blindTestVM.appleMusicService.setupAudioSession()

                Task {
                    await blindTestVM.appleMusicService.setupAppleMusic()
                    await blindTestVM.updateCatalogPlaybackCapability()
                }
            }
        }
        // Alerte abonnement/fallback preview
        .alert("Information", isPresented: $blindTestVM.showSubscriptionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(blindTestVM.subscriptionAlertMessage)
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(ambiantaudioPlayerVM: AmbiantSoundViewModel(), blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
}
