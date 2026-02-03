//
//  ButtonChooseGameView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import SwiftUI

struct ButtonChooseGameView: View {
    let isOpen: Bool
    let action: () -> Void
    let title: String
    let iconName: String
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 40) {
                    Image(systemName: iconName)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.white)
                                .opacity(0.1)
                        )
                    Text(title)
                        .font(.nohemi(.headline, weight: .black))
                        .foregroundStyle(.white)
                }
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .frame(minWidth: 200)
                        .background {
                            RoundedRectangle(cornerRadius: 18)
                                .foregroundStyle(.white.opacity(0.1))
                                .opacity(isOpen ? 1 : 0.8)
                        }
                
                    
             
                    
                    Text(isOpen ? "Open" : "Close")
                        .foregroundStyle(isOpen ? Color.darkestPurple : Color.white)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(isOpen ? .green : .red)
                        }
                        .padding()
                
            }
        }
        .disabled(!isOpen)
        .animation(.default, value: isOpen)
       
    }
}


#Preview {
    ButtonChooseGameView(isOpen: false, action: {}, title: "BlindTest", iconName: "brain")
        .frame(maxHeight: .infinity)
        .background(
           BackgroundAppView()
        )
}
