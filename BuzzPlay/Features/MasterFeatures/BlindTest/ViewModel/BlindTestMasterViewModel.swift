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
class BlindTestMasterViewModel: BuzzDrivenGame {
    var gameVM: MasterFlowViewModel
    
    //MARK: données de manche en cours
    var isPlaying: Bool = false
    var songs: [Song] = songsData
    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var teamHasBuzz: Team? = nil
    
    var state: RoundState = .idle
    
    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?

    
    enum RoundState {
        case idle // next song and master hasn't lunch round/music
        case playing // in game and music playing
        case buzzed(Team) // response receive
        case finished // state finished when Master validate response
    }
    
    
    
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
            startRound()
            
            isPlaying = gameAudioPlayer.play()
        } catch {
            print("Error playing sound: \(error)")
            isPlaying = false
        }
    
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
extension BlindTestMasterViewModel {
    
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
    
    
     
    

    /// Valide la réponse de l'équipe gagnante (teamWining)
    /// Arrête la manche et fige le temps
    func validateAnswer() {
        guard let teamAnswers = teamHasBuzz else { return }
        
        isCorrect = true
        state = .finished
        
         // MARK: mise à jour du score via gameVM.addPoints(...)
        gameVM.addPointToTeam(teamAnswers)
        
        // on fige définitivement la manche
        stopReactionTimer()
        gameAudioPlayer.pause()
        isPlaying = false
        
        
      
    }
    
    /// Refuse la réponse de l'équipe qui a buzzé
    /// Reprend la manche là où elle avait été mise en pause
    func rejectAnswer() {
        // si aucune équipe n'avait buzzé, on ne fait rien
        guard case .buzzed = state else { return }
        
        isCorrect = false
        teamHasBuzz = nil
        state = .playing
        
        // on redémarre le timer sans reset (reprise de la manche) et autorise les buzz
        gameVM.unlockBuzz()
        startReactionTimer()
        
        // on relance la musique à partir de là où elle avait été mise en pause
        gameAudioPlayer.play()
        isPlaying = true
    }
    
    func goToNextSong() {
        stopReactionTimer()         // on arrête le timer, il reste figé
        reactionTimeMs = 0   // on reset l’affichage
        teamHasBuzz = nil
        isCorrect = false
        state = .idle        // la prochaine manche commencera au prochain Play
        nextSong()           // on change de chanson
       
    }
    
    
    //MARK: Team Datas dans Funtions
    func registerBuzz(from team: Team) {
        handleBuzz(from: team)
    }
}





//MARK: Round Funcs
extension BlindTestMasterViewModel {
    func startRound() {
        reactionTimeMs = 0      // nouvelle manche → on reset
        teamHasBuzz = nil
        isCorrect = false
        state = .playing
        gameVM.unlockBuzz()
        startReactionTimer()
        
    }
}

//MARK: BuzzDrivenGame conformance
extension BlindTestMasterViewModel {
    func handleBuzz(from team: Team) {
        // Ignorer les buzz si la manche n'est pas en cours
        guard case .playing = state else { return }
        
        teamHasBuzz = team
        state = .buzzed(team)
        
        // On fige le timer et on met la musique en pause au moment du buzz
        stopReactionTimer()
        gameAudioPlayer.pause()
        isPlaying = false
    }
    
    
   
    
}
