//
//  ShapeExtensions.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI


//MARK: ShapeStyle



extension RoundedRectangle {
    @ViewBuilder
    static func backgroundPrimaryButton(style: Style) -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .circular)
        
        if style == .filled {
            shape
                .fill(Color.darkPurple)
        } else if style == .outlined {
            shape
                .strokeBorder(Color.darkPurple, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        } else {
            shape
        }
        
    }
}


//    static let backgroundPrimaryButton: RoundedRectangle = RoundedRectangle(cornerRadius: 8, style: .circular).fill(Color.darkPurple)


