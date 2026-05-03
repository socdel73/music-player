import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selector de Biblioteca
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
                        Task { await viewModel.folderChanged(to: newValue) }
                    }
                }
                
                // Graella d'Àlbums
                ScrollView {
                    if viewModel.isLoading && viewModel.albums.isEmpty {
                        ProgressView("Connectant a Nebraska...").padding(.top, 50)
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
            
        }
        .navigationTitle("SocDel73 Player")
#if os(iOS)
        // Aquesta part només s'executarà en iPhone i iPad
        .navigationViewStyle(StackNavigationViewStyle())
#endif
        .task {
            await viewModel.setup()
        }
    }
    
}

