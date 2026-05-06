// ViewModels/LibraryViewModel.swift

import Foundation
import Combine

@MainActor // Ens assegurem que qualsevol canvi a @Published es faci al fil principal
class LibraryViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var folders: [MusicFolder] = []
    @Published var selectedFolderId: Int? = nil
    @Published var isLoading: Bool = false
    
    private let service = NavidromeService()
    
    /// Configuració inicial de la biblioteca
    func setup() async {
        // Evitem recarregar si ja tenim dades
        guard albums.isEmpty else { return }
        
        isLoading = true
        // Executem ambdues càrregues en paral·lel per eficiència
        async let fetchedFolders = fetchFolders()
        async let fetchedAlbums = fetchAlbums()
        
        _ = await (fetchedFolders, fetchedAlbums)
        isLoading = false
    }
    
    /// Obté les carpetes de música (Biblioteques: Bruce, CDs, etc.)
    func fetchFolders() async {
        do {
            self.folders = try await service.fetchMusicFolders()
        } catch {
            print("❌ Error Folders: \(error.localizedDescription)")
        }
    }
    
    /// Obté la llista d'àlbums (recentment afegits)
    func fetchAlbums() async {
        do {
            // Cridem al servei asíncron de forma directa
            self.albums = try await service.fetchRecentAlbums(folderId: selectedFolderId)
        } catch {
            print("❌ Error Albums: \(error.localizedDescription)")
        }
    }
    
    /// Reacciona al canvi de filtre de biblioteca
    func folderChanged(to newId: Int?) async {
        selectedFolderId = newId
        isLoading = true
        await fetchAlbums()
        isLoading = false
    }
}
