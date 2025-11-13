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
    var body: some Scene {
        WindowGroup {
           BlindTestMasterView()
                .environmentObject(router)
        }
    }
}
