//
//  ExternalDisplayManager .swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation


//import UIKit
//import SwiftUI
//
//final class ExternalDisplayManager {
//    static let shared = ExternalDisplayManager()
//    
//    private var externalWindow: UIWindow?
//    
//    private init() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(screenDidConnect),
//            name: UIScreen.didConnectNotification,
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(screenDidDisconnect),
//            name: UIScreen.didDisconnectNotification,
//            object: nil
//        )
//    }
//    
//    /// Affiche une vue SwiftUI sur l'écran externe (si dispo)
//    func present<V: View>(_ view: V) {
//        guard UIScreen.screens.count > 1 else {
//            print("No external screen available")
//            return
//        }
//        
//        let externalScreen = UIScreen.screens[1]
//        let window = UIWindow(frame: externalScreen.bounds)
//        window.screen = externalScreen
//        window.rootViewController = UIHostingController(rootView: view)
//        window.isHidden = false
//        
//        externalWindow = window
//    }
//    
//    func clear() {
//        externalWindow?.isHidden = true
//        externalWindow = nil
//    }
//    
//    // MARK: - Notifications
//    
//    @objc private func screenDidConnect(_ notification: Notification) {
//        print("External screen connected")
//    }
//    
//    @objc private func screenDidDisconnect(_ notification: Notification) {
//        print("External screen disconnected")
//        clear()
//    }
//}
