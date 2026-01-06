//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    
    @Bindable var ambiantaudioPlayerVM: AmbiantSoundViewModel

    @Bindable var blindTestVM: BlindTestMasterViewModel

    var body: some View {
        VStack {
            
            AmbiantSoundsPadView(ambiantAudioPlayerVM: ambiantaudioPlayerVM, blindTestVM: blindTestVM)
            
            HStack {
                
                songDataToShow(song: blindTestVM.songNowPlaying)
                
                
                //MARK: Music Play/Pause from Master
                VStack {
                    PrimaryButtonView(title: "Lecture", action: {
                        blindTestVM.playSound()
                    }, style: .filled(color: .darkestPurple), fontSize: Typography.largeTitle)
                   // .disabled(ambiantaudioPlayerVM.isPlaying)
                    
                    PrimaryButtonView(title: "Question suivante", action: {
                                    blindTestVM.goToNextSong()  // reset timer + change de chanson, sans play
                                }, style: .filled(color: .darkestPurple),
                                   fontSize: Typography.largeTitle)
                    .disabled(!blindTestVM.isCorrect)
                }
//                .frame(width: 120)
            }
            
            
            //MARK: Correct answer or Wrong answer
            VStack {
                HStack {
                    PrimaryButtonView(title: "Valider la réponse", action: {
                        blindTestVM.validateAnswer()
                    }, style: .filled(color: .green), fontSize: Typography.largeTitle)
                    
                    
                    PrimaryButtonView(title: "Refuser la réponse", action: {
                        blindTestVM.rejectAnswer()
                    }, style: .filled(color: .red), fontSize: Typography.largeTitle)
                    
                }
               
            }
           
                
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(ambiantaudioPlayerVM: AmbiantSoundViewModel(), blindTestVM: BlindTestMasterViewModel(gameVM: MasterFlowViewModel()))
}
