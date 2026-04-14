//
//  BuzzerPlayerView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct BuzzerPlayerView: View {
    @Bindable var teamGameVM: TeamGameViewModel
    var gameType: GameType

    var body: some View {
        if let buzzerVM = teamGameVM.currentBuzzerVM {
            BuzzerButtonView(buzzerVM: buzzerVM)
        } else {
            ContentUnavailableView("Pas de buzzer", systemImage: "exclamationmark.triangle")
        }
    }
}

#Preview {
    BuzzerPlayerView(
        teamGameVM: TeamGameViewModel(
            team: Team(name: "Team1", teamColor: .blueGame),
            mpc: MPCService(peerName: "Team1", role: .team)
        ),
        gameType: .blindTest
    )
}
