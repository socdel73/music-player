// Models/Credentials.swift (O dins de AuthManager)
struct Credentials: Codable {
    let url: String
    let user: String
    let token: String
    let salt: String
}
