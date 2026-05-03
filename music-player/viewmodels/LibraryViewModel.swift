// viewmodels/LibraryViewModel.swift

import Foundation
import SwiftUI
import Combine // <--- AQUESTA és la peça que falta per als errors de @Published

@MainActor
class LibraryViewModel: ObservableObject {
    // Propietats que la vista observarà
    @Published var albums: [Album] = []
    @Published var folders: [MusicFolder] = []
    @Published var selectedFolderId: Int? = nil
    @Published var isLoading: Bool = false
    
    private let service = NavidromeService()
    
    // Funció inicial
    func setup() async {
        guard albums.isEmpty else { return } // Evitem recarregar si ja tenim dades
        isLoading = true
        await fetchFolders()
        await fetchAlbums()
        isLoading = false
    }
    
    // Obtenir carpetes (Fase 3)
    func fetchFolders() async {
        do {
            let fetchedFolders = try await service.fetchMusicFolders()
            self.folders = fetchedFolders
        } catch {
            print("❌ Error ViewModel Folders: \(error)")
        }
    }
    
    // Obtenir àlbums (amb o sense filtre)
    func fetchAlbums() async {
        // Com que fetchRecentAlbums encara usa closures, el cridem així:
        service.fetchRecentAlbums(folderId: selectedFolderId) { [weak self] result in
            // Ens assegurem de tornar al fil principal per actualitzar la UI
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedAlbums):
                    self?.albums = fetchedAlbums
                case .failure(let error):
                    print("❌ Error ViewModel Albums: \(error)")
                }
            }
        }
    }
    
    // Acció quan l'usuari canvia el picker
    func folderChanged(to newId: Int?) async {
        selectedFolderId = newId
        await fetchAlbums()
    }
}
