import Foundation

// Les capes per desembolicar la resposta de Nebraska
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

// L'objecte Llibreria (Ex: ID: 1, Name: "Directes Nugs")
struct MusicFolder: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}
