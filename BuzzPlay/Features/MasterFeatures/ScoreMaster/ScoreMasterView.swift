//
//  ScoreMasterView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 09/01/2026.
//

import SwiftUI

struct ScoreMasterView: View {
    var masterFlowVM: MasterFlowViewModel
    var body: some View {
        
        //Ladder Teams sorted by scores
        ScrollView(.horizontal) {
            HStack {
                ForEach(masterFlowVM.teams.sorted(by: { $0.score > $1.score })) { team in
                    TeamCardView(team: team, showPoints: true)
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundAppView()
        )
    }
}

#Preview {
    ScoreMasterView(masterFlowVM: MasterFlowViewModel())
}
