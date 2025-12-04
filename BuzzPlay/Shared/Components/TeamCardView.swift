//
//  TeamCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI


struct TeamCardView: View {
    var team: Team
    var buzzTime: String?
    var isWining: Bool = false
    var body: some View {
      
            
            ZStack(alignment: .bottom) {
                
                VStack(alignment: .leading) {
                    Text(team.name)
                    if let buzzTime = buzzTime {
                        Text("\(buzzTime)")
                    }
                    if !isWining {
                        
                        
                        ForEach(team.players.indices, id: \.self) { playerIndex in
                            HStack {
                                Text("\(playerIndex + 1).")
                                    .font(.poppins(.title))
                                Text(team.players[playerIndex].name)
                                    .font(.poppins(.title))
                                    .frame(alignment: .leading)
                            }

                        }
                       
                    }
                }
                .padding()
                .frame(alignment: .top)
                .background {
                    RoundedRectangle(cornerRadius: 8, )
                    //MARK: Couleur de l'équipe qui a buzzé
                        .foregroundStyle(Color(team.teamColor.rawValue))
                }
                
                //MARK: Affiché si le master valide la réponse
                if isWining {
                    Text("Bonne Réponse !")
                        .padding(.bottom)
                }
               
            }
            .font(.poppins(.largeTitle, weight: .bold))
            .foregroundStyle(Color.darkestPurple)
            
        
    }
}

#Preview {
    TeamCardView(team: Team(name: "La Team", players: [Player(name: "kikoo"), Player(name: "Romain")]))
}
