////
////  PublicDisplayViewModel.swift
////  BuzzPlay
////
////  Created by Apprenant 102 on 20/11/2025.
////
//
//import Foundation
//
//@Observable
//class PublicDisplayViewModel {
//    
//    var state: PublicState = .waiting
//    var teamGameVM: TeamGameViewModel
//    var hasStartedBrowsing: Bool = false
//    
//    
//    private var timer: Timer?
//    private var reactionTimeMs: Int = 0
//    private var lastQuestionID: UUID?
//    
//    var formattedTime: String {
//        let centiseconds = reactionTimeMs / 10
//        let seconds = centiseconds / 100
//        let cs = centiseconds % 100
//        return String(format: "%02d:%02d", seconds, cs)
//    }
//    
//    init(teamGameVM: TeamGameViewModel) {
//        self.teamGameVM = teamGameVM
//        
//        
//    }
//    
//    //TODO: send publicDisplay isActive -> and handleMessage de TeamGameVM change values for the PublicDisplayScreen
//    
//    //MPC Service / State
//    private func setupMPC(_ mpc: MPCService) {
//        mpc.onMessage = { [weak self] data, peer in
//            guard let self else { return }
//            
//            if let update = try? JSONDecoder().decode(PublicState.self, from: data) {
//                self.state = update
//                self.handleStateChange()
//            }
//        }
//    }
//    
//    //MPC Browsing verification
////    private func startBrowsingPublicDisplay() {
////        guard !hasStartedBrowsing else { return }
////        hasStartedBrowsing = true
////        print("TEAM Starting MPC browsing...")
////        mpc.onPeerConnected = { [weak self] peer in
////                guard let self else { return }
////
////                print("PUBLIC DISPLAY connected to MASTER → sending teamJoin")
////                
////                let displayTeam = Team(name: "DisplayPublic")
////                self.mpc.sendMessage(.teamJoin(displayTeam))
////            }
////
////            mpc.startBrowsingIfNeeded()
////    }
//    
//}
//
//
////MARK: Timer StateChange (Timer) receive
//extension PublicDisplayViewModel {
//    private func handleStateChange() {
//        switch state {
//        case .waiting:
//            stopTimer(reset: true)
//        case .quiz(let quiz):
//            if lastQuestionID != quiz.question.id {
//                state = .quiz(quiz)
//                lastQuestionID = quiz.question.id
//                reactionTimeMs = 0
//                
//            }
//            if quiz.buzzingTeam != nil {
//                //quelqu'un a buzzé
//                state = .quiz(quiz)
//                stopTimer(reset: false)
//            } else {
//                //pas encore de buzz
//                startTimerIfNeeded()
//            }
//        }
//    }
//    
//    
//    private func startTimerIfNeeded() {
//        guard timer == nil else { return }
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
//            self?.reactionTimeMs += 100
//        })
//    }
//    
//    private func stopTimer(reset: Bool) {
//        timer?.invalidate()
//        timer = nil
//        if reset {
//            reactionTimeMs = 0
//        }
//    }
//}
