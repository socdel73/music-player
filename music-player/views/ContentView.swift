// views/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        // NavigationStack és el successor modern de NavigationView (iOS 16+ / macOS 13+)
        NavigationStack {
            VStack(spacing: 0) {
                // Selector de Biblioteca (Adaptatiu)
                if !viewModel.folders.isEmpty {
                    Picker("Biblioteca", selection: $viewModel.selectedFolderId) {
                        Text("Totes").tag(nil as Int?)
                        ForEach(viewModel.folders) { folder in
                            Text(folder.name).tag(folder.id as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
                
                // Graella d'Àlbums
                ScrollView {
                    if viewModel.isLoading && viewModel.albums.isEmpty {
                        ProgressView("Connectant a Nebraska...")
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: layoutColumns), spacing: 16) {
                            ForEach(viewModel.albums) { album in
                                NavigationLink(value: album) {
                                    AlbumCardView(album: album)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("SocDel73 Player")
            // Destinacions de navegació modernes
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
            // Toolbar multiplataforma amb botó de Logout
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Sortir", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .help("Tancar sessió de Nebraska") // Només es veu a macOS al passar el ratolí
                }
            }
            .task {
                await viewModel.setup()
            }
        }
    }
    
    // Lògica simple per adaptar columnes segons plataforma
    private var layoutColumns: Int {
#if os(macOS)
        return 4 // A Nebraska (Mac) volem veure més caràtules
#else
        return 2 // A l'iPhone, dues columnes és l'estàndard audiòfil
#endif
    }
}
