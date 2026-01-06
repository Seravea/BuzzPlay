//
//  PublicDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicDisplayView: View {
    // Centralize rendering based on the team view model
    @Bindable var teamGameVM: TeamGameViewModel

    var body: some View {
        VStack {
            switch teamGameVM.publicState {
            case .waiting:
                Text("Choix de la question en cours")
                Text("Préparez-vous !")

            case .quiz(let state):
                // Use the view model's formatted time
                PublicQuizDisplayView(state: state, timer: teamGameVM.formattedTime)
            }
        }
    }
}

#Preview {
    // Minimal preview scaffolding
    let vm = TeamGameViewModel(team: Team(name: "Preview Team"),
                               mpc: MPCService(peerName: "Preview", role: .team),
                               clientMode: .team)
    return PublicDisplayView(teamGameVM: vm)
}

