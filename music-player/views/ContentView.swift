import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !viewModel.folders.isEmpty {
                    Picker("Biblioteca", selection: $viewModel.selectedFolderId) {
                        Text("Totes").tag(nil as Int?)
                        ForEach(viewModel.folders) { folder in
                            Text(folder.name).tag(folder.id as Int?)
                        }
                    }
                    .pickerStyle(.segmented).padding()
                    .onChange(of: viewModel.selectedFolderId) { _ in
                        Task { await viewModel.fetchAlbums() }
                    }
                }
                
                ScrollView {
                    if viewModel.isLoading { ProgressView().padding(.top, 50) }
                    else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.albums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumCardView(album: album)
                                }
                            }
                        }.padding()
                    }
                }
            }
            .navigationTitle("SocDel73 Player")
            .task { await viewModel.setup() }
        }
    }
}
