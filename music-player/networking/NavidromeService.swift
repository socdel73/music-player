import Foundation

class NavidromeService {
    // ⚙️ La nostra estructura de configuració (baseURL, seguretat MD5, etc.)
    private let config = SubsonicConfig()
    
    // MARK: - 1. LLIBRERIES (Carpetes Físiques)
    /// Demana a Nebraska quines carpetes de música tenim (ex: "Nugs", "CDs")
    func fetchMusicFolders(completion: @escaping (Result<[MusicFolder], Error>) -> Void) {
        let urlString = "\(config.baseURL)/getMusicFolders?\(config.generateAuthParams())"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubsonicFoldersResponse.self, from: data)
                completion(.success(response.subsonicResponse.musicFolders.musicFolder))
            } catch {
                print("❌ Error descodificant carpetes: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - 2. ÀLBUMS
    /// Obté els 200 àlbums més recents. Permet filtrar per la llibreria seleccionada per evitar duplicats.
    func fetchRecentAlbums(folderId: Int? = nil, completion: @escaping (Result<[Album], Error>) -> Void) {
        // Fem servir 'var' per poder modificar la URL si cal aplicar el filtre
        var urlString = "\(config.baseURL)/getAlbumList2?type=newest&size=200&\(config.generateAuthParams())"
        
        // Si l'usuari ha triat una carpeta al Picker, apliquem el filtre a Nebraska
        if let id = folderId {
            urlString += "&musicFolderId=\(id)"
        }
        
        guard let url = URL(string: urlString) else {
            print("⚠️ URL de Nebraska mal formada")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubsonicResponse.self, from: data)
                let albums = response.subsonicResponse.albumList2.album
                completion(.success(albums))
            } catch {
                print("❌ Error descodificant àlbums: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - 3. CARÀTULES
    /// Construeix la URL per a que SwiftUI pugui descarregar la caràtula en segon pla (AsyncImage)
    func getCoverArtURL(coverId: String) -> URL? {
        let urlString = "\(config.baseURL)/getCoverArt?id=\(coverId)&size=300&\(config.generateAuthParams())"
        return URL(string: urlString)
    }

    // MARK: - 4. TRACKLIST (Pistes)
    /// Obté la llista de cançons (FLACs/MP3) d'un àlbum en concret quan hi fem clic
    func fetchTracks(for albumId: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        let urlString = "\(config.baseURL)/getAlbum?id=\(albumId)&\(config.generateAuthParams())"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubsonicAlbumResponse.self, from: data)
                // Si l'àlbum està buit, retornem un array buit '[]' per no fer petar l'app
                let songs = response.subsonicResponse.album.song ?? []
                completion(.success(songs))
            } catch {
                print("❌ Error descodificant les cançons: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    // MARK: - 5. STREAMING DE SO
    /// Genera la URL directa perquè el motor de so xucli el FLAC bit a bit
    func getStreamURL(for songId: String) -> URL? {
        // FASE 2: Exigim el Bit-Perfect des de l'origen.
        // - format=raw: Prohibeix qualsevol transcodificació (evita que passi FLAC a MP3).
        // - maxBitRate=0: Elimina el límit d'ample de banda que podria forçar un downsampling.
        let urlString = "\(config.baseURL)/stream?id=\(songId)&\(config.generateAuthParams())&format=raw&maxBitRate=0"
        return URL(string: urlString)
    }
}
