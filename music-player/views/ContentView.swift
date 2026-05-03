import SwiftUI

struct ContentView: View {
    // 1. Instanciem el ViewModel (ell gestionarà l'estat)
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // 2. Selector de Biblioteca (Llegeix del ViewModel)
                if !viewModel.folders.isEmpty {
                    Picker("Biblioteca", selection: $viewModel.selectedFolderId) {
                        Text("Totes").tag(nil as Int?)
                        ForEach(viewModel.folders) { folder in
                            Text(folder.name).tag(folder.id as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: viewModel.selectedFolderId) { newValue in
                        // Deleguem la càrrega al ViewModel
                        Task {
                            await viewModel.folderChanged(to: newValue)
                        }
                    }
                }
                
                // 3. Graella d'Àlbums
                ScrollView {
                    if viewModel.isLoading && viewModel.albums.isEmpty {
                        ProgressView("Connectant a Nebraska...")
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.albums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumCardView(album: album)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("SocDel73 Player")
            // 4. Disparador inicial
            .task {
                await viewModel.setup()
            }
        }
    }
}
