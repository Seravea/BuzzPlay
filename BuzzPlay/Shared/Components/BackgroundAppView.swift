//
//  BackgroundAppView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/01/2026.
//

import SwiftUI

struct BackgroundAppView: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color.sheetBg, location: 0),
                .init(color: Color.darkestPurple, location: 0.5),
                .init(color: Color.darkPurple, location: 1),
            ],
            startPoint: .init(x: 0.2, y: 0),
            endPoint: .init(x: 0.8, y: 1)
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundAppView()
}
