import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @StateObject var viewModel = AlbumDetailViewModel()
    @ObservedObject var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Llista de cançons
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscant FLACs a Nebraska...")
                    Spacer()
                } else {
                    List {
                        // Capçalera amb info de l'àlbum (opcional per ara)
                        Section(header: Text("Cançons")) {
                            ForEach(viewModel.songs) { song in
                                SongRow(song: song) {
                                    audioManager.startPlayback(
                                        songs: viewModel.songs,
                                        fromIndex: viewModel.songs.firstIndex(where: { $0.id == song.id }) ?? 0,
                                        inAlbum: album
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            // El reproductor que veies a la captura
            reproductorInferior
        }
        .navigationTitle(album.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            // Usem .task en lloc d'onAppear per a millor gestió asíncrona
            await viewModel.loadSongs(for: album.id)
        }
    }
    
    // Component de la fila de la cançó
    struct SongRow: View {
        let song: Song
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text("\(song.track ?? 0)").foregroundColor(.secondary).frame(width: 30)
                    Text(song.title).foregroundColor(.primary)
                    Spacer()
                    if let duration = song.duration {
                        Text(formatTime(Double(duration))).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    var reproductorInferior: some View {
        VStack(spacing: 10) {
            // Barra de progrés
            if audioManager.duration > 0 {
                ProgressView(value: audioManager.currentTime, total: audioManager.duration)
                    .tint(.blue)
            }
            
            HStack(spacing: 40) {
                Button(action: { audioManager.previousTrack() }) {
                    Image(systemName: "backward.fill").font(.title2)
                }
                
                Button(action: { audioManager.togglePlayPause() }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: { audioManager.nextTrack() }) {
                    Image(systemName: "forward.fill").font(.title2)
                }
            }
            
            // Etiqueta Audiòfila
            if audioManager.currentSampleRate > 0 {
                Text("BIT-PERFECT: \(Int(audioManager.currentSampleRate/1000))kHz")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding()
    }
}

// Helper per al temps
func formatTime(_ seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let seconds = Int(seconds) % 60
    return String(format: "%d:%02d", minutes, seconds)
}
