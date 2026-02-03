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
            HStack {
                Text(team.name)
                    
                
                Spacer()
                
                if showPoints {
                    Text("\(team.score) pts")
                        
                }
            }
            .font(.nohemi(.title2, weight: .bold))
            
            HStack {
                ForEach(team.players) { player in
                    Text(player.name)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .foregroundStyle(.white.opacity(0.4))
                        )
                }
            }
            
        }
        .padding()
        .foregroundStyle(.black)
        .background(
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(
                LinearGradient(colors: [.white.opacity(0), .white.opacity(0.1), .white.opacity(0.1), .white.opacity(0.1), .white.opacity(0.2), .white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
            )
        )
        .padding(.trailing, -8)
        
//        .appDefaultTextStyle(Typography.body)
        .padding(.leading, 6)
        .background(
            HStack {
                RoundedRectangle(cornerRadius: 16)
                
                    .foregroundStyle(/*Color(team.teamColor.rawValue).opacity(0.3)*/
                    
                        LinearGradient(colors: [Color(team.teamColor.rawValue).opacity(1), Color(team.teamColor.rawValue).opacity(0.7), Color(team.teamColor.rawValue).opacity(0.5),Color(team.teamColor.rawValue).opacity(0.3), Color(team.teamColor.rawValue).opacity(0.2), Color(team.teamColor.rawValue).opacity(0)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(maxWidth: 100, alignment: .leading)
                Spacer()
            }
        )
        
        .padding()
        
//        VStack(alignment: .leading) {
//            
//            Text(team.name)
//                .font(.poppins(.title, weight: .semiBold))
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.bottom, 4)
//                
//            
//            if let buzzTime = buzzTime {
//                HStack {
//                    Image(systemName: "hourglass")
//                    Text("\(buzzTime)")
//                }
//            }
//            
//            if showPoints {
//                HStack {
//                    Image(systemName: "trophy")
//                        .fontWeight(.medium)
//                    Text("\(team.score) point\(team.score > 1 ? "s" : "")")
//                }
//                .font(.poppins(.title3, weight: .medium))
//                .padding(.bottom, 4)
//            }
//                ForEach(team.players) { player in
//                    Text("- \(player.name)")
//                }
//                
//            
//            
//        }
//        .frame(minHeight: 230, alignment: .top)
//                .padding()
//                .background {
//                    RoundedRectangle(cornerRadius: 8)
//                    //MARK: Couleur de l'équipe qui a buzzé
//                        .foregroundStyle(Color(team.teamColor.rawValue))
//                        .overlay(.thinMaterial)
//                        .cornerRadius(8)
//                }
                
            //MARK: Affiché si le master valide la réponse
            //TODO: bonne réponse ?
               
            
        
        
    }
}

#Preview {
    TeamCardView(team: sampleTeams[0], showPoints: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
         BackgroundAppView()
        )
}
