//
//  Router.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import Observation
import SwiftUI



@MainActor
final class Router {
    var path = NavigationPath()
    var modal: Bool = false
    
    func push(_ route: Route) { path.append(route) }
    func popToRoot() { path = NavigationPath() }
    func presentModal() { self.modal = true }
    func dismissModal() { self.modal = false }
    
    
}
