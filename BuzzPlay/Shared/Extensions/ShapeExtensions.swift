//
//  ShapeExtensions.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI


//MARK: ShapeStyle



extension View {
    
    @ViewBuilder
       static func backgroundPrimaryButton(style: Style) -> some View {
           let shape = RoundedRectangle(cornerRadius: 8, style: .circular)

           switch style {
           case .filled:
               shape.fill(style.gradient)

           case .outlined, .default:
               shape.strokeBorder(style.gradient, lineWidth: 2)
           }
       }
//        if style == .filled(buttonStyle: .destructive) {
//            shape
//                .fill(style.color)
//                .fill(
//                    style.gradient
//                )
//                .opacity(0.8)
//        } else if style == .outlined(color: style.gradient) {
//            shape
//                .strokeBorder(style.gradient, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
//        } else {
//            shape
//        }
        
    
}


//    static let backgroundPrimaryButton: RoundedRectangle = RoundedRectangle(cornerRadius: 8, style: .circular).fill(Color.darkPurple)


