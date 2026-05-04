import SwiftUI

@main
struct music_playerApp: App {
    // Injectem l'AuthManager com a StateObject per tota l'app
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                // Aquí posa el nom de la teva vista principal actual (podria ser ContentView)
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
