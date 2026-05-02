// viewmodels/AlbumDetailViewModel.swift

import Foundation
import Combine

class AlbumDetailViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading = false
    
    // Instanciem el teu servei actual
    private let navidromeService = NavidromeService()
    
    func loadSongs(for albumId: String) {
        self.isLoading = true
        
        navidromeService.fetchTracks(for: albumId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let fetched) = result {
                    self?.songs = fetched
                } else if case .failure(let error) = result {
                    print("Error carregant cançons: \(error.localizedDescription)")
                }
            }
        }
    }
}
