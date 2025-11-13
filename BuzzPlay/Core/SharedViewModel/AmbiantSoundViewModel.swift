//
//  AmbiantSoundViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import Foundation
import AVFoundation
import Observation


@Observable
class AmbiantSoundViewModel: ObservableObject {
    let songs: [String] = ["BeginQuestion", "Blblbl", "GoodAnswer", "WrongAnswer", "HeavenlyChoir", "Mosquito", "PositiveAnswer", "Tired"]
    
     var isPlaying: Bool = false
    
     var player: AVAudioPlayer = AVAudioPlayer()
    
    
    
    func playSound(song: String) {
        guard let soundURL = Bundle.main.url(forResource: song, withExtension: "mp3") else { return }
        do {
            player.stop() // stop() is not throwing
            player = try AVAudioPlayer(contentsOf: soundURL)
            isPlaying = player.play()
        } catch {
            print("Error playing sound: \(error)")
            isPlaying = false
        }
    }
    
    
}
