import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var serverURL: String = ""
    
    private let serviceName = "com.socdel73.player.auth"
    private let accountName = "nebraska_credentials"
    
    struct Credentials: Codable {
        let url: String
        let user: String
        let token: String // Guardarem el token o el password encriptat
        let salt: String
    }
    
    init() {
        checkStatus()
    }
    
    func checkStatus() {
        if let data = KeychainHelper.standard.read(service: serviceName, account: accountName) {
            // Si podem llegir i decodificar, estem autenticats
            self.isAuthenticated = true
            // Aquí carregarem la configuració per al NetworkManager
        } else {
            self.isAuthenticated = false
        }
    }
    
    // Afegeix això dins de la class AuthManager a // viewmodels/AuthManager.swift
    
    func getCredentials() -> Credentials? {
        // 1. Intentem llegir les dades binàries del Keychain
        guard let data = KeychainHelper.standard.read(service: serviceName, account: accountName) else {
            return nil
        }
        
        // 2. Intentem transformar el binari (JSON) a la nostra estructura Credentials
        do {
            let creds = try JSONDecoder().decode(Credentials.self, from: data)
            return creds
        } catch {
            print("❌ Error decodificant credencials: \(error)")
            return nil
        }
    }
    
    func saveCredentials(url: String, user: String, pass: String) {
        // 1. Generem un Salt (cadena aleatòria)
        let salt = String(UUID().uuidString.prefix(6))
        
        // 2. Creem el Token: md5(password + salt)
        let combined = pass + salt
        let token = combined.md5() // Necessitarem una extensió de MD5 que farem ara
        
        let creds = Credentials(url: url, user: user, token: token, salt: salt)
        
        // 3. Codifiquem i guardem al Keychain
        if let encoded = try? JSONEncoder().encode(creds) {
            KeychainHelper.standard.save(encoded, service: serviceName, account: accountName)
            self.isAuthenticated = true
            self.serverURL = url
        }
    }
    
    func logout() {
        KeychainHelper.standard.delete(service: serviceName, account: accountName)
        isAuthenticated = false
    }
}
