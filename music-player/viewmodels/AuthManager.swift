import Foundation
import SwiftUI
import Combine
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    // SINGLETON: Garantim que tota l'app consulti la mateixa instància de seguretat
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var userCredentials: Credentials?
    
    // Identificadors únics per al Keychain del sistema
    private let serviceName = "com.socdel73.player.auth"
    private let accountName = "nebraska_credentials"
    
    // El constructor intenta recuperar la sessió de Nebraska automàticament
    init() {
        self.refreshSession()
    }
    
    /// Carrega les credencials del Keychain a la memòria RAM
    func refreshSession() {
        if let creds = self.getCredentials() {
            self.userCredentials = creds
            self.isAuthenticated = true
            print("✅ AuthManager: Sessió de Nebraska recuperada per a \(creds.user)")
        } else {
            self.isAuthenticated = false
            print("ℹ️ AuthManager: No hi ha sessió activa.")
        }
    }
    
    /// Lectura segura del Keychain
    func getCredentials() -> Credentials? {
        guard let data = KeychainHelper.standard.read(service: serviceName, account: accountName) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Credentials.self, from: data)
        } catch {
            print("❌ AuthManager: Error decodificant dades: \(error)")
            return nil
        }
    }
    
    /// Guarda la sessió i activa l'estat autenticat
    func saveCredentials(url: String, user: String, pass: String) {
        // Generació de token Subsonic: md5(password + salt)
        let salt = String(UUID().uuidString.prefix(6))
        let token = (pass + salt).md5()
        
        let creds = Credentials(url: url, user: user, token: token, salt: salt)
        
        do {
            let encoded = try JSONEncoder().encode(creds)
            KeychainHelper.standard.save(encoded, service: serviceName, account: accountName)
            
            // Actualitzem l'estat per disparar la UI
            self.userCredentials = creds
            self.isAuthenticated = true
            print("✅ AuthManager: Credencials desades al Keychain.")
        } catch {
            print("❌ AuthManager: No s'han pogut codificar les credencials.")
        }
    }
    
    /// Tanca la sessió i neteja el rastre digital
    func logout() {
        KeychainHelper.standard.delete(service: serviceName, account: accountName)
        
        // Neteja immediata de la memòria
        self.userCredentials = nil
        self.isAuthenticated = false
        
        print("🚪 AuthManager: Sessió de Nebraska finalitzada.")
    }
}
