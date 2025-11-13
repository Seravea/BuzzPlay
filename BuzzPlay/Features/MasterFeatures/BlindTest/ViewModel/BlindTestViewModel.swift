//
//  BlindTestViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import Observation


@Observable
class BlindTestViewModel: ObservableObject {
    //MARK: données de manche en cours
    var isPlaying: Bool = false
    var songs: [Song] = songsData
    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    
    var questionNumber: Int {
        nowPlayingSongIndex + 1
    }
    
    //MARK: données de jeu
    var totalNumberOfSongs: Int {
        songs.count
    }
    
    var progressValue: Double {
        Double(questionNumber) / Double(totalNumberOfSongs)
    }
    
    var progressText: String {
        "Question \(questionNumber)/\(totalNumberOfSongs)"
    }
    
    
    var gameAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    
    
    
    //MARK: Player functions
   func playSound() {
       
        guard let soundURL = Bundle.main.url(forResource: songs[nowPlayingSongIndex].id, withExtension: "mp3") else { return }
        do {
            gameAudioPlayer.stop() // stop() is not throwing
            gameAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            isPlaying = gameAudioPlayer.play()
        } catch {
            print("Error playing sound: \(error)")
            isPlaying = false
        }
    
    }
    
   func pauseSong() {
       gameAudioPlayer.pause()
        isPlaying = false
    }

  func nextSong() {
      if nowPlayingSongIndex < songs.count - 1 {
            nowPlayingSongIndex += 1
        } else {
            nowPlayingSongIndex = 0
        }
        
    }
}
