//
//  QuizMasterViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation

//TODO: des états du jeux :
// - Le master est en train de choisir une question
// - debut de la manche avec la question choisi (quiz en cours)
// - une equipe a buzzé - pause
// - relance le jeux (quiz en cours (même état que debut de manche je pense)
// - validate() réponse ( les points son affichés a tout le monde)
// -> le master choisi une autre question (reprise de l'etat a 0)



@Observable
class QuizMasterViewModel: BuzzDrivenGame {
    
    
    
    let gameVM: MasterFlowViewModel
    
    var questions: [QuizQuestion] = quizMusic90sTo10s
    var currentQuestion: QuizQuestion?
    var teamHasBuzz: Team?
    
    var questionsPassed: [QuizQuestion] = []
    
    
    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?
    
    
    
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }
}

//MARK: Quiz Functions
extension QuizMasterViewModel {
    func selectQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        teamHasBuzz = nil
        
        gameVM.unlockBuzz()
        startRound()
    }
    
    func startRound() {
        //SI pas de question ne peu pas commencer la manche
        guard currentQuestion != nil else { return }
        
        //TODO: envoyer la question aux teams (MPC)
        
        gameVM.broadcastPublicStateFromCurrentGame()
        gameVM.unlockBuzz()
        //TODO: start Timer for the DisplayPublic
        startReactionTimer()
    }
    
    func validateAnswer() {
        if let team = gameVM.currentBuzzTeam {
            gameVM.addPointToTeam(team)
            goToSelectNewQuestion()
            
            
            
        }
        //TODO: etat du jeux pour question suivante etc..
        
        
    }
    
    func rejectAnswer() {
        gameVM.unlockBuzz()
        startReactionTimer()
    }
    
    func handleBuzz(from team: Team) {
        gameVM.currentBuzzTeam = team
        teamHasBuzz = team
        pauseReactionTimer()
        
        //TODO: handle du buzz pour le Quiz a voir s'il est différent du BlindTestVM handleBuzz(team)
        
    }
    
    func goToSelectNewQuestion() {
        if let currentQuestion = currentQuestion {
            questionsPassed.append(currentQuestion)
        }
        stopReactionTimer()
        currentQuestion = nil
        teamHasBuzz = nil
        gameVM.currentBuzzTeam = nil
        
        let state = makePublicState()
        gameVM.sendPublicState(state)
    }
    
}


//MARK: Quiz UI details
extension QuizMasterViewModel {
    func questionButtonStyle(_ question: QuizQuestion) -> Style {
        var isSelected: Bool  {
            question == currentQuestion
        }
        
        var isAlreadyPassed: Bool {
            questionsPassed.contains(question)
        }
        if isSelected {
            return .filled(color: .darkestPurple)
        } else if isAlreadyPassed {
            return .filled(color: .green)
        } else {
            return .outlined(color: .darkestPurple)
            
        }
    }
    
    func quizButtonDisabled(question: QuizQuestion) -> Bool {
        if isPlaying {
            return true
        } else if questionsPassed.contains(question) {
            return true
        } else {
            return false
        }
    }
    
    var isPlaying: Bool {
        currentQuestion != nil
    }
    
    var validateRejectDisabled: Bool {
        if teamHasBuzz == nil {
            return true
        } else {
            return false
        }
    }
    
    func UIDisabledValidateRejectButtonOpacity() -> Double {
        if validateRejectDisabled {
            return 0.6
        } else {
            return 1
        }
    }
}


//MARK: making/sending Payload to peers
extension QuizMasterViewModel {
    func makePublicState() -> PublicState {
        guard let question = currentQuestion else {
            return .waiting
        }
        
        return PublicState.quiz(
            PublicQuizState(
                question: question,
                formattedTime: formattedTime,
                buzzingTeam: teamHasBuzz,
                isAnswerRevealed: false,
                isHintVisible: false
            )
        )
    }
}
