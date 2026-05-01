import Foundation

// 1. La capa exterior del JSON
struct SubsonicResponse: Codable {
    let subsonicResponse: SubsonicData
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

// 2. La capa intermèdia
struct SubsonicData: Codable {
    let albumList2: AlbumList2
}

// 3. La llista d'àlbums
struct AlbumList2: Codable {
    let album: [Album]
}

// 4. El nostre objecte principal: L'Àlbum
struct Album: Identifiable, Codable {
    let id: String
    let name: String
    let artist: String
    let year: Int?
    let coverArt: String?
    
    var isLive: Bool {
        name.contains("-") || name.lowercased().contains("live")
    }
}
