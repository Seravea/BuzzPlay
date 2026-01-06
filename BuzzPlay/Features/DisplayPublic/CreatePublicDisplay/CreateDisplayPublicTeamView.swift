//
//  CreateDisplayPublicTeamView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 28/11/2025.
//

import SwiftUI

struct CreateDisplayPublicTeamView: View {
    @Bindable var createTeamVM: CreateTeamViewModel
    @EnvironmentObject var router: Router
    @State var isNavigateAlertOn: Bool = false
    
    var body: some View {
        Button {
            createTeamVM.isAlertOn = true
        } label: {
            Text("Rejoindre le jeu")
        }
        
        .onAppear {
            createTeamVM.loadDisplayTeam()
        }
        
        .alert("Es-tu sûr des prénoms de tes joueurs ?", isPresented: $createTeamVM.isAlertOn) {
            Button("Annuler", role: .destructive) {
                createTeamVM.isAlertOn = false
            }
            
            Button("Continuer", role: .cancel) {
                createTeamVM.validate(isPublicDisplay: true)
                
                router.push(.publicDisplayScreen)
               
            }
            
        }
        
    }
}

#Preview {
    CreateDisplayPublicTeamView(createTeamVM: CreateTeamViewModel())
}
