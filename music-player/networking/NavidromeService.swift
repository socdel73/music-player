// Networking/NavidromeService.swift

import Foundation

class NavidromeService {
    private let api = SubsonicAPI.shared // Utilitzem el Singleton de l'API
    
    /// Construeix la base de la URL de Nebraska afegint la ruta /rest
    private func getBaseURL() -> String? {
        // Obtenim les credencials actuals de l'AuthManager (Singleton)
        guard let creds = AuthManager.shared.userCredentials else {
            print("❌ NavidromeService: No hi ha credencials")
            return nil
        }
        
        let cleanedURL = creds.url.hasSuffix("/") ? creds.url : "\(creds.url)/"
        return "\(cleanedURL)rest"
    }
    
    // MARK: - 1. LIBRARIES (Biblioteques de Nebraska)
    func fetchMusicFolders() async throws -> [MusicFolder] {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let urlString = "\(baseURL)/getMusicFolders?\(authParams)"
        print("🌐 Intentant connectar a Nebraska: \(urlString)")
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(SubsonicFoldersResponse.self, from: data)
        return decodedResponse.subsonicResponse.musicFolders?.musicFolder ?? []    }
    
    // MARK: - 2. ALBUMS (Graella Audiòfila)
    func fetchRecentAlbums(folderId: Int? = nil) async throws -> [Album] {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // Construïm la URL base
        var urlString = "\(baseURL)/getAlbumList2?type=newest&size=200&\(authParams)"
        
        // Reintroduïm el filtre per carpeta (Bruce vs CD)
        if let id = folderId {
            urlString += "&musicFolderId=\(id)"
        }
        
        print("🌐 Intentant connectar a Nebraska: \(urlString)")
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            // Intentem decodificar amb el model genèric que hem creat
            let decodedResponse = try JSONDecoder().decode(SubsonicResponse<SubsonicAlbumListResult>.self, from: data)
            let albums = decodedResponse.subsonicResponse.albumList2?.album ?? []
            
            print("📦 Nebraska ha enviat \(albums.count) àlbums.")
            return albums
            
        } catch {
            // Aquest print és el que ens salvarà la vida si el JSON canvia
            print("❌ Error de Decodificació d'Àlbums: \(error)")
            
            // Debug extra: Imprimeix el JSON rebut si vols veure què ha enviat Nebraska realment
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 JSON rebut de Nebraska: \(jsonString)")
            }
            
            throw error
        }
    }
    
    // MARK: - 3. TRACKLIST (Llista de cançons)
    func fetchTracks(for albumId: String) async throws -> [Song] {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let urlString = "\(baseURL)/getAlbum?id=\(albumId)&\(authParams)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(SubsonicAlbumResponse.self, from: data)
        return decodedResponse.subsonicResponse.album.song ?? []
    }
    
    // MARK: - 4. STREAMING (Prioritat Bit-Perfect)
    func getStreamURL(for songId: String) -> URL? {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            return nil
        }
        
        // No demanem compressió: Navidrome servirà el FLAC/ALAC original si no especifiquem format.
        let urlString = "\(baseURL)/stream?id=\(songId)&\(authParams)"
        return URL(string: urlString)
    }
    
    // MARK: - 5. CARÀTULES
    func getCoverArtURL(coverId: String) -> URL? {
        // Utilitzem el Singleton de l'API per generar la URL amb el token de Nebraska
        return SubsonicAPI.shared.getCoverArtURL(id: coverId)
    }
}
