//
//  PrivateMasterBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI



struct PrivateMasterBlindTestView: View {
    
    @StateObject var ambiantaudioPlayerVM = AmbiantSoundViewModel()

    @ObservedObject var blindTestVM: BlindTestViewModel

    var body: some View {
        VStack {
            
            AmbiantSoundsPadView(ambiantAudioPlayerVM: ambiantaudioPlayerVM, blindTestVM: blindTestVM)
            
            HStack {
                
                songDataToShow(song: blindTestVM.songNowPlaying)
                
                
                //MARK: Music Play/Pause from Master
                VStack {
                    PrimaryButtonView(title: "Play", action: {
                        blindTestVM.playSound()
                    }, style: .filled(color: .darkestPurple), fontSize: Typography.largeTitle)
                   // .disabled(ambiantaudioPlayerVM.isPlaying)
                    PrimaryButtonView(title: "Pause", action: {
                        blindTestVM.pauseSong()
                    }, style: .outlined(color: .darkestPurple), fontSize: Typography.largeTitle)
                }
//                .frame(width: 120)
            }
            
            
            //MARK: Correct answer or Wrong answer
            HStack {
                PrimaryButtonView(title: "Valider", action: {
                    blindTestVM.isCorrectAnswer()
                }, style: .filled(color: .green), fontSize: Typography.largeTitle)
                
                
                PrimaryButtonView(title: "Refuser", action: {
                    blindTestVM.isWrongAnswer()
                }, style: .filled(color: .red), fontSize: Typography.largeTitle)
                
            }
           
                
        }
    }
}

#Preview {
    PrivateMasterBlindTestView(blindTestVM: BlindTestViewModel(gameVM: MasterFlowViewModel()))
}
