//
//  BuzzPlayApp.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import SwiftUI
import UIKit

@main
struct BuzzPlayApp: App {
    @StateObject private var router = Router()

    init() {
        UIWindow.appearance().backgroundColor = UIColor(red: 0x1A/255, green: 0x05/255, blue: 0x35/255, alpha: 1)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(router)
                .appDefaultTextStyle(Typography.body)
        }
    }
}
