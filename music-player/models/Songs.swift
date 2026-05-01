import Foundation

// Aquestes estructures obren les "capes" del JSON específic d'un àlbum
struct SubsonicAlbumResponse: Codable {
    let subsonicResponse: SubsonicAlbumData
    
    enum CodingKeys: String, CodingKey {
        case subsonicResponse = "subsonic-response"
    }
}

struct SubsonicAlbumData: Codable {
    let album: AlbumDetail
}

struct AlbumDetail: Codable {
    let id: String
    let song: [Song]? // Opcional, per si algun disc està buit
}

// El nostre objecte Cançó pur
struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let track: Int?      // Número de pista
    let duration: Int?   // Durada en segons
    let suffix: String?  // El format de l'arxiu (flac, mp3, m4a...)
    
    // Un petit "truc" de disseny: convertim els segons en minuts:segons
    var formattedDuration: String {
        guard let duration = duration else { return "0:00" }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
