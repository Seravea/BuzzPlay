//
//  BackgroundAppView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/01/2026.
//

import SwiftUI

struct BackgroundAppView: View {
    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "1A0535"), location: 0),
                        .init(color: Color(hex: "2A0944"), location: 0.5),
                        .init(color: Color(hex: "3B185F"), location: 1),
                    ],
                    startPoint: .init(x: 0.2, y: 0),
                    endPoint: .init(x: 0.8, y: 1)
                )
            )
    }
}

#Preview {
    BackgroundAppView()
}
