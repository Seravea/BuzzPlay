//
//  BuzzPlayApp.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI

@main
struct BuzzPlayApp: App {
    @StateObject private var router = Router()

    init() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    var body: some Scene {
        WindowGroup {
          HomeView()
                .environmentObject(router)
                .appDefaultTextStyle(Typography.body)
        }
    }
}
