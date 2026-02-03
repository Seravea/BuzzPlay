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
                LinearGradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
}

#Preview {
    BackgroundAppView()
}
