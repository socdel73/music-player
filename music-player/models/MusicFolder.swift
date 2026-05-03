import Foundation

// El contenidor principal de la resposta de l'API
struct SubsonicFoldersResponse: Codable {
    let subsonicResponse: SubsonicFoldersData
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

struct SubsonicFoldersData: Codable {
    let musicFolders: MusicFoldersList
}

struct MusicFoldersList: Codable {
    let musicFolder: [MusicFolder]
}

/// L'objecte que representa una "Biblioteca" a Nebraska (ex: "CDs", "Directes Nugs")
struct MusicFolder: Identifiable, Codable, Hashable {
    let id: Int // Navidrome utilitza Ints per als IDs de carpetes
    let name: String
    
    // Identifiable requereix un ID únic, l'Int ja ens serveix
}
