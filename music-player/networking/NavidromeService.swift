import Foundation

// Definim les respostes aquí mateix si no les troba en altres fitxers per garantir que compile


class NavidromeService {
    private let api = SubsonicAPI()
    
    private func getBaseURL() -> String? {
        let auth = AuthManager()
        guard let creds = auth.getCredentials() else { return nil }
        return creds.url.hasSuffix("/") ? "\(creds.url)rest" : "\(creds.url)/rest"
    }
    
    // MARK: - 1. LIBRARIES
    func fetchMusicFolders() async throws -> [MusicFolder] {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let urlString = "\(baseURL)/getMusicFolders?\(authParams)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(SubsonicFoldersResponse.self, from: data)
        return decodedResponse.subsonicResponse.musicFolders.musicFolder
    }
    
    // MARK: - 2. ALBUMS
    func fetchRecentAlbums(folderId: Int? = nil, completion: @escaping (Result<[Album], Error>) -> Void) {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        var urlString = "\(baseURL)/getAlbumList2?type=newest&size=200&\(authParams)"
        if let id = folderId { urlString += "&musicFolderId=\(id)" }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SubsonicAlbumListResponse.self, from: data)
                completion(.success(decodedResponse.subsonicResponse.albumList2.album))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 3. TRACKLIST
    func fetchTracks(for albumId: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        let urlString = "\(baseURL)/getAlbum?id=\(albumId)&\(authParams)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SubsonicAlbumResponse.self, from: data)
                let songs = decodedResponse.subsonicResponse.album.song ?? []
                completion(.success(songs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    // MARK: - 4. CARÀTULES
    func getCoverArtURL(coverId: String) -> URL? {
        // Cridem al mètode que ja hem definit a la nostra lògica d'API
        return api.getCoverArtURL(id: coverId)
    }
    // MARK: - 5. STREAMING (So Audiòfil)
    func getStreamURL(for songId: String) -> URL? {
        guard let authParams = api.generateAuthParams(),
              let baseURL = getBaseURL() else {
            return nil
        }
        
        // Construïm la URL de stream. Navidrome retornarà el FLAC original si no especifiquem format.
        let urlString = "\(baseURL)/stream?id=\(songId)&\(authParams)"
        return URL(string: urlString)
    }
}
