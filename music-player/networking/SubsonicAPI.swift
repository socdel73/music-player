import Foundation
import CryptoKit

struct SubsonicAPI {
    

    
    private func getConfig() -> (url: String, user: String, token: String, salt: String)? {
        // Creem una instància interna per llegir directament
        let auth = AuthManager.shared
        
        // Si Xcode segueix protestant aquí, és perquè getCredentials necessita ser accessible.
        guard let creds = auth.getCredentials() else { return nil }
        return (creds.url, creds.user, creds.token, creds.salt)
    }
    
    let apiVersion = "1.16.1"
    static let shared = SubsonicAPI()
    
#if os(iOS)
    let clientName = "dPlayer-iOS"
#else
    let clientName = "dPlayer-OSX"
#endif
    
    func generateAuthParams() -> String? {
        // Utilitzem el shared per garantir que llegim les credencials actuals
        guard let creds = AuthManager.shared.userCredentials else { return nil }
        
        let user = creds.user
        let token = creds.token
        let salt = creds.salt
        let version = "1.16.1" // Versió estàndard de l'API
        let client = "SocDel73Player"
        
        // Crucial: format=json és obligatori perquè el nostre Decoder no sap llegir XML
        return "u=\(user)&t=\(token)&s=\(salt)&v=\(version)&c=\(client)&f=json"
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
