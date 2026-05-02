// networking/SubsonicAPI.swift

import Foundation
import CryptoKit

struct SubsonicConfig {
    let baseURL = Secrets.baseURL + "/rest"
    let user = Secrets.apiUser
    let password = Secrets.apiPassword
    
    let apiVersion = "1.16.1"
    let clientName = "socdel73-player"
    
    func generateAuthParams() -> String {
        let salt = String(Int.random(in: 100000...999999))
        let payload = password + salt
        
        let hash = Insecure.MD5.hash(data: payload.data(using: .utf8)!)
        let token = hash.map { String(format: "%02hhx", $0) }.joined()
        
        return "u=\(user)&t=\(token)&s=\(salt)&v=\(apiVersion)&c=\(clientName)&f=json"
    }
    
    // NOU: Afegim el control de mida de la caràtula
    func getCoverArtURL(id: String, size: Int = 600) -> URL? {
        let auth = generateAuthParams()
        let urlString = "\(baseURL)/getCoverArt?id=\(id)&\(auth)&size=\(size)"
        return URL(string: urlString)
    }
}
