import SwiftUI

struct ContentView: View {
    // La nostra música
    @State private var albums: [Album] = []
    
    // El nostre "Selector d'Entrades" (Nugs, CDs, etc.)
    @State private var folders: [MusicFolder] = []
    // IMPORTANT: Ara és String? (amb interrogant, perquè pot ser 'nil' si ho volem veure tot)
    @State private var selectedFolderId: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                // EL SELECTOR D'ENTRADES (Picker)
                // Només el mostrem si el servidor ens ha retornat carpetes
                if !folders.isEmpty {
                    Picker("Llibreria", selection: $selectedFolderId) {
                        // L'opció per defecte: Tota la biblioteca
                        Text("Totes les llibreries").tag(Int?.none)
                        
                        // Iterem per les teves carpetes (ex: Nugs)
                        ForEach(folders) { folder in
                            Text(folder.name).tag(Int?.some(folder.id))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    // Si toques el botó i canvies de carpeta, demanem la música de nou
                    .onChange(of: selectedFolderId) { newValue in
                        loadAlbums(folderId: newValue)
                    }
                }
                
                // LA LLISTA DE DISCOS
                if albums.isEmpty {
                    Spacer()
                    Image(systemName: "music.note.house.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .padding(.bottom, 5)
                    Text("Connectant a Nebraska...")
                        .font(.headline)
                    Spacer()
                } else {
                    List(albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(album.name)
                                    .font(.headline)
                                Text(album.artist)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("SocDel73 Player")
        }
        .onAppear {
            // 1. En obrir l'app, demanem a l'API quines carpetes físiques tens
            NavidromeService().fetchMusicFolders { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedFolders) = result {
                        self.folders = fetchedFolders
                    }
                }
            }
            // 2. I carreguem els àlbums
            loadAlbums(folderId: selectedFolderId)
        }
    }
    
    // Funció auxiliar per carregar la música. Ara accepta String?
    private func loadAlbums(folderId: Int?) {
        albums = [] // Buidem la UI mentre descarreguem les dades noves
        let service = NavidromeService()
        
        service.fetchRecentAlbums(folderId: folderId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedAlbums):
                    self.albums = fetchedAlbums
                case .failure(let error):
                    print("❌ Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
