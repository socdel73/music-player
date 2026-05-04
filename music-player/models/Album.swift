import Foundation

// 1. La capa exterior del JSON (General)
struct SubsonicResponse: Codable {
    let subsonicResponse: SubsonicData
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

// 2. Estructura per a Llistes d'Àlbums (Recent, Newest, etc.)
struct SubsonicAlbumListResponse: Codable {
    let subsonicResponse: SubsonicAlbumListContent
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

struct SubsonicAlbumListContent: Codable {
    let albumList2: AlbumList2
}

struct AlbumList2: Codable {
    let album: [Album]
}

// 3. Contingut de dades genèric (per a altres crides)
struct SubsonicData: Codable {
    let albumList2: AlbumList2?
    // Aquí anirem afegint musicFolders, etc. a mesura que calgui
}

// 4. L'objecte principal: L'Àlbum
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
