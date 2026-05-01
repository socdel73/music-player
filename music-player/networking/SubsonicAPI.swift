import Foundation
import CryptoKit

struct SubsonicConfig {
    // Ara injectem els valors des del fitxer Secrets que Git no veu
    let baseURL = Secrets.baseURL + "/rest"
    let user = Secrets.apiUser
    let password = Secrets.apiPassword
    
    let apiVersion = "1.16.1"
    let clientName = "socdel73-player"
    
    func generateAuthParams() -> String {
        let salt = String(Int.random(in: 100000...999999))
        let payload = password + salt
        
        // Seguretat MD5: Navidrome mai rep la teva pass, només el token calculat
        let hash = Insecure.MD5.hash(data: payload.data(using: .utf8)!)
        let token = hash.map { String(format: "%02hhx", $0) }.joined()
        
        return "u=\(user)&t=\(token)&s=\(salt)&v=\(apiVersion)&c=\(clientName)&f=json"
    }
}
