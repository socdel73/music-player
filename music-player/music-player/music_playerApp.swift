// music_playerApp.swift

import SwiftUI

@main
struct music_playerApp: App {
    // Injectem l'AuthManager com a StateObject per tota l'app
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                // Si estem loguejats, anem a la biblioteca
                ContentView()
                    .environmentObject(authManager)
            } else {
                // Si no, forcem el Login
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
