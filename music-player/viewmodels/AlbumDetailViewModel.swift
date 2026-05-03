import Foundation
import Combine

@MainActor // Crucial per evitar l'error de "view updates"
class AlbumDetailViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading: Bool = false
    
    private let service = NavidromeService()
    
    func loadSongs(for albumId: String) async {
        guard !isLoading else { return }
        isLoading = true
        
        service.fetchTracks(for: albumId) { [weak self] result in
            switch result {
            case .success(let fetchedSongs):
                self?.songs = fetchedSongs
            case .failure(let error):
                print("❌ Error carregant cançons: \(error)")
            }
            self?.isLoading = false
        }
    }
}
