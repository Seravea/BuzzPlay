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
    let fontSize: Typography.Token
    var sfIconName: String? = nil
    var iconSize: Font? = nil
    var colorIcon: Color? = nil
    var size: CGFloat? = nil
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .primaryButtonTextStyle(style, fontSize: fontSize)
                    
                
                if let iconName = sfIconName, let iconSize = iconSize, let colorIcon = colorIcon {
                    Image(systemName: iconName)
                        .font(iconSize)
                        .foregroundStyle(colorIcon)
                        .padding(.leading, 8)
                }
               
            }
            .frame(maxWidth: size ?? .infinity)
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
        PrimaryButtonView(title: "Valider", action: {}, style: .filled(color: .darkestPurple), fontSize: Typography.body)
        PrimaryButtonView(title: "Annuler", action: {}, style: .outlined(color: .darkestPurple), fontSize: Typography.body)
    }
}


