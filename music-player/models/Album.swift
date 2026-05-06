import Foundation

// Contenidor Arrel per a qualsevol resposta de Nebraska
struct SubsonicResponse<T: Codable>: Codable {
    let subsonicResponse: T
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

// Resultat específic per a Llistes d'Àlbums
struct SubsonicAlbumListResult: Codable {
    let status: String
    let version: String
    let albumList2: AlbumList2Container?
    
    enum CodingKeys: String, CodingKey {
        case status, version, albumList2
    }
}

struct AlbumList2Container: Codable {
    let album: [Album]
}

// L'objecte Àlbum (El cor de la col·lecció)
struct Album: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let artist: String?
    let year: Int?
    let coverArt: String?
    
    // Swift genera automàticament Hashable/Equatable si els camps ho són
}
