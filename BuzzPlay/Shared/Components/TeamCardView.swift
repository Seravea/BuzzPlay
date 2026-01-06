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
    var showPoints: Bool
    var body: some View {
      
            
                
        VStack(alignment: .leading) {
            
            Text(team.name)
                .font(.poppins(.title, weight: .semiBold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
                
            
            if let buzzTime = buzzTime {
                HStack {
                    Image(systemName: "hourglass")
                    Text("\(buzzTime)")
                }
            }
            
            if showPoints {
                HStack {
                    Image(systemName: "trophy")
                        .fontWeight(.medium)
                    Text("\(team.score) point\(team.score > 1 ? "s" : "")")
                }
                .font(.poppins(.title3, weight: .medium))
                .padding(.bottom, 4)
                
                ForEach(team.players) { player in
                    Text("- \(player.name)")
                }
                
            }
            
        }
        .frame(minHeight: 230, alignment: .top)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                    //MARK: Couleur de l'équipe qui a buzzé
                        .foregroundStyle(Color(team.teamColor.rawValue))
                        .overlay(.thinMaterial)
                        .cornerRadius(8)
                }
                
            //MARK: Affiché si le master valide la réponse
            //TODO: bonne réponse ?
               
            
           
        
    }
}

#Preview {
    TeamCardView(team: sampleTeams[0], showPoints: true)
}
