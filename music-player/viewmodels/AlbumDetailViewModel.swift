// ViewModels/AlbumDetailViewModel.swift

import Foundation
import Combine

@MainActor // Crucial per a l'actualització de la UI sense glitches
class AlbumDetailViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading: Bool = false
    
    private let service = NavidromeService()
    
    func loadSongs(for albumId: String) async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            // Cridem al mètode asíncron que hem definit al Service
            let fetchedSongs = try await service.fetchTracks(for: albumId)
            self.songs = fetchedSongs
        } catch {
            print("❌ Error carregant cançons de Nebraska: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
}
