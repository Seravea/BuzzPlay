//
//  TeamCardView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI


struct TeamCardView: View {
    var teamWining: Team
    var buzzTime: Double
    var body: some View {
      
            
            ZStack(alignment: .bottom) {
                
                VStack {
                    Text(teamWining.name)
                    
                    Text("\(buzzTime)")
                }
                .padding()
                .frame(minHeight: 400, alignment: .top)
                .background {
                    Rectangle()
                    //MARK: Couleur de l'équipe qui a buzzé
                        .foregroundStyle(Color.darkestPurple)
                }
                
                //MARK: Affiché si le master valide la réponse
                Text("Bonne Réponse !")
                    .padding(.bottom)
            }
            .font(.poppins(.largeTitle, weight: .bold))
            .foregroundStyle(.white)
            
        
    }
}

#Preview {
    TeamCardView(teamWining: Team(name: "La Team", colorIndex: 1), buzzTime: 0.1)
}
