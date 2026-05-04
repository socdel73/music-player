import Foundation
import CryptoKit

struct SubsonicAPI {
    
    private func getConfig() -> (url: String, user: String, token: String, salt: String)? {
        // Creem una instància interna per llegir directament
        let auth = AuthManager()
        
        // Si Xcode segueix protestant aquí, és perquè getCredentials necessita ser accessible.
        guard let creds = auth.getCredentials() else { return nil }
        return (creds.url, creds.user, creds.token, creds.salt)
    }
    
    let apiVersion = "1.16.1"
    
#if os(iOS)
    let clientName = "dPlayer-iOS"
#else
    let clientName = "dPlayer-OSX"
#endif
    
    // Ara aquesta funció ja no necessita calcular res, només agafa el que hi ha al Keychain
    func generateAuthParams() -> String? {
        guard let config = getConfig() else { return nil }
        
        // Retornem la cadena d'autenticació ja muntada
        return "u=\(config.user)&t=\(config.token)&s=\(config.salt)&v=\(apiVersion)&c=\(clientName)&f=json"
    }
    
    func getCoverArtURL(id: String, size: Int = 600) -> URL? {
        guard let config = getConfig(),
              let authParams = generateAuthParams() else { return nil }
        
        // Netegem la URL base per assegurar-nos que acaba en /rest
        let baseURL = config.url.hasSuffix("/") ? "\(config.url)rest" : "\(config.url)/rest"
        
        let urlString = "\(baseURL)/getCoverArt?id=\(id)&\(authParams)&size=\(size)"
        return URL(string: urlString)
    }
    
}
