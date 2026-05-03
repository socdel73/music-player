import SwiftUI // <--- AQUESTA LÍNIA ÉS OBLIGATÒRIA

struct ContentView: View {
    // 1. ESTAT DE LES DADES
    @State private var albums: [Album] = []
    @State private var folders: [MusicFolder] = []
    @State private var selectedFolderId: Int? = nil
    
    // Instanciem el servei
    private let service = NavidromeService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 2. SELECTOR DE BIBLIOTECA (La teva "Brúixola")
                if !folders.isEmpty {
                    Picker("Biblioteca", selection: $selectedFolderId) {
                        Text("Totes").tag(nil as Int?)
                        ForEach(folders) { folder in
                            Text(folder.name).tag(folder.id as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
                
                // 3. LA GRALLA D'ÀLBUMS
                // Dins de ContentView.swift, a la secció 3 (LA GRALLA D'ÀLBUMS)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(albums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                // Utilitzem el nou component que hem creat
                                AlbumCardView(album: album)
                            }
                            .buttonStyle(PlainButtonStyle()) // Evita que el text es torni blau per ser un link
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("SocDel73 Player")
            
            // 4. LÒGICA DE CÀRREGA ASÍNCRONA (Fase 3)
            .task {
                await loadInitialData()
            }
            // 5. REACCIÓ AL CANVI DE FILTRE
            .onChange(of: selectedFolderId) { newValue in
                loadAlbums(folderId: newValue)
            }
        }
    }
    
    // --- FUNCIONS DE SUPORT ---
    
    private func loadInitialData() async {
        do {
            let fetchedFolders = try await service.fetchMusicFolders()
            await MainActor.run {
                self.folders = fetchedFolders
            }
            loadAlbums(folderId: nil)
        } catch {
            print("❌ Error inicial: \(error)")
        }
    }
    
    private func loadAlbums(folderId: Int?) {
        service.fetchRecentAlbums(folderId: folderId) { result in
            switch result {
            case .success(let fetchedAlbums):
                DispatchQueue.main.async {
                    self.albums = fetchedAlbums
                }
            case .failure(let error):
                print("❌ Error carregant àlbums: \(error)")
            }
        }
    }
}
