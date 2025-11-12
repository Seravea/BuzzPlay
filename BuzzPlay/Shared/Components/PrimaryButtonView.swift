//
//  PrimaryButtonView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI

struct PrimaryButtonView: View {
    let title: String
    let action: () -> Void
    let style: Style
    let fontSize: Font
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .primaryButtonTextStyle(style, fontSize: Typography.title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
                .background {
                    RoundedRectangle.backgroundPrimaryButton(style: style)
                }
                
        }
        //MARK: TO DELET a enlever et mettre qu'une seul fois dans le @main App project
        .appDefaultTextStyle(Typography.body)
    }
}

#Preview {
    VStack {
        PrimaryButtonView(title: "Valider", action: {}, style: .filled(color: .darkestPurple), fontSize: .body)
        PrimaryButtonView(title: "Annuler", action: {}, style: .outlined(color: .darkestPurple), fontSize: .body)
    }
}


