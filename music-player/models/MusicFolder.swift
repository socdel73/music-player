import Foundation

struct SubsonicFoldersResponse: Codable {
    let subsonicResponse: SubsonicFoldersResult
    
    enum CodingKeys: String, CodingKey {
        // Crucial: Navidrome envia "subsonic-response" amb guionet
        case subsonicResponse = "subsonic-response"
    }
}

struct SubsonicFoldersResult: Codable {
    let status: String
    let version: String
    let musicFolders: MusicFoldersContainer?
    
    enum CodingKeys: String, CodingKey {
        case status, version, musicFolders
    }
}

struct MusicFoldersContainer: Codable {
    let musicFolder: [MusicFolder]
}

struct MusicFolder: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}
