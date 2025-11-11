//
//  ViewExtensions.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import SwiftUI


enum Style {
    case filled
    case outlined
    case `default`
}



//MARK: Text Extension

extension Text {
    func primaryButtonTextStyle(_ style: Style, fontSize: Font) -> some View {
        switch style {
        case .filled:
            return self
                .foregroundStyle(.white)
                .font(fontSize)
        case .outlined:
            return self
                .foregroundStyle(Color.darkPurple)
                .font(fontSize)
        case .default:
            return self
                .font(fontSize)
        }
    }
}



//MARK: filled
//    .background(.purple)
//    .clipShape(
//        RoundedRectangle(cornerRadius: 8)
//    )

//MARK: outlined
//    .background(.purple)
//    .clipShape(
//        RoundedRectangle(cornerRadius: 8)
//            .stroke(lineWidth: 2)
//    )




