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
class BlindTestViewModel {
    var gameVM: MasterFlowViewModel
    
    //MARK: données de manche en cours
    var isPlaying: Bool = false
    var songs: [Song] = songsData
    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var teamWining: Team? = nil
    
    var buzzTime: String? = nil
    
    var gameTimer: String = "00:00"
    
    
    
    //MARK: données de jeu
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }
    
    var gameAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    
    
    
    //MARK: Player functions
    func playSound() {
       
        guard let soundURL = Bundle.main.url(forResource: songs[nowPlayingSongIndex].id, withExtension: "mp3") else { return }
        do {
            gameAudioPlayer.pause() // stop() is not throwing
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

  private func nextSong() {
      if nowPlayingSongIndex < songs.count - 1 {
            nowPlayingSongIndex += 1
        } else {
            nowPlayingSongIndex = 0
        }
        
    }
}


//MARK: func and data use in the View
extension BlindTestViewModel {
    
    //MARK: Questions Datas and Functions
    var songNowPlaying: Song {
        songs[nowPlayingSongIndex]
    }
    
    var questionNumber: Int {
        nowPlayingSongIndex + 1
    }
    
    
    var totalNumberOfSongs: Int {
        songs.count
    }
    
    var progressValue: Double {
        Double(questionNumber) / Double(totalNumberOfSongs)
    }
    
    var progressText: String {
        "Question \(questionNumber)/\(totalNumberOfSongs)"
    }
    
    
    func isCorrectAnswer() {
        isCorrect = true
        nextSong()
    }
    
    func isWrongAnswer() {
        isCorrect = false
        playSound()
    }
    
    
    
    //MARK: Team Datas dans Funtions
    
}
