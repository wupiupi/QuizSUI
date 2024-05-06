//
//  QuizSUIApp.swift
//  QuizSUI
//
//  Created by Paul Makey on 5.05.24.
//

import SwiftUI
import Firebase

@main
struct QuizSUIApp: App {
    /// - Initializing Firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
