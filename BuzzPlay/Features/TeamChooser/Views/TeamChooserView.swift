//
//  TeamChooserView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import SwiftUI

struct TeamChooserView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Début de jeux")
                
                  Spacer()
                
                HStack {
                    //MARK: Destination to PlayerView
                    PrimaryButtonView(title: "Joueurs", action: {}, style: .filled, fontSize: .largeTitle)
                     
                    //MARK: Destination to MasterView
                    PrimaryButtonView(title: "Maître", action: {}, style: .outlined, fontSize: .largeTitle)
                  
                }
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    TeamChooserView()
}
