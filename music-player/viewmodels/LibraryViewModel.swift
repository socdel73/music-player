import Foundation
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var folders: [MusicFolder] = []
    @Published var selectedFolderId: Int? = nil
    @Published var isLoading: Bool = false
    
    private let service = NavidromeService()
    
    func setup() async {
        guard albums.isEmpty else { return }
        isLoading = true
        await fetchFolders()
        await fetchAlbums()
        isLoading = false
    }
    
    func fetchFolders() async {
        do { self.folders = try await service.fetchMusicFolders() }
        catch { print("❌ Error Folders: \(error)") }
    }
    
    func fetchAlbums() async {
        service.fetchRecentAlbums(folderId: selectedFolderId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let fetched) = result { self?.albums = fetched }
            }
        }
    }
    
    func folderChanged(to newId: Int?) async {
        selectedFolderId = newId
        await fetchAlbums()
    }
}
