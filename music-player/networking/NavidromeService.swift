import Foundation

class NavidromeService {
    // ⚙️ Configuració de connexió (URL, credencials, MD5)
    private let config = SubsonicConfig()
    
    // MARK: - 1. LLIBRERIES (Carpetes Físiques) - ACTUALITZAT ASYNC
    /// Demana a Nebraska quines carpetes de música tenim (ex: "Nugs", "CDs")
    /// Migrat a Async/Await per a la Fase 3.
    func fetchMusicFolders() async throws -> [MusicFolder] {
        let urlString = "\(config.baseURL)/getMusicFolders?\(config.generateAuthParams())"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(SubsonicFoldersResponse.self, from: data)
        
        return decodedResponse.subsonicResponse.musicFolders.musicFolder
    }
    
    // MARK: - 2. ÀLBUMS (Legacy Closure)
    /// Obté els 200 àlbums més recents.
    func fetchRecentAlbums(folderId: Int? = nil, completion: @escaping (Result<[Album], Error>) -> Void) {
        var urlString = "\(config.baseURL)/getAlbumList2?type=newest&size=200&\(config.generateAuthParams())"
        
        if let id = folderId {
            urlString += "&musicFolderId=\(id)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubsonicResponse.self, from: data)
                let albums = response.subsonicResponse.albumList2.album
                completion(.success(albums))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 3. CARÀTULES
    func getCoverArtURL(coverId: String) -> URL? {
        let urlString = "\(config.baseURL)/getCoverArt?id=\(coverId)&size=300&\(config.generateAuthParams())"
        return URL(string: urlString)
    }
    
    // MARK: - 4. TRACKLIST (Legacy Closure)
    func fetchTracks(for albumId: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        let urlString = "\(config.baseURL)/getAlbum?id=\(albumId)&\(config.generateAuthParams())"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubsonicAlbumResponse.self, from: data)
                let songs = response.subsonicResponse.album.song ?? []
                completion(.success(songs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 5. STREAMING DE SO (Bit-Perfect)
    func getStreamURL(for songId: String) -> URL? {
        // FASE 2: Forcem format RAW per evitar transcodificació al servidor Nebraska
        let urlString = "\(config.baseURL)/stream?id=\(songId)&\(config.generateAuthParams())&format=raw&maxBitRate=0"
        return URL(string: urlString)
    }
}
