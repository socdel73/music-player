// views/AlbumDetailView.swift

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    
    // 1. Instanciem el nou ViewModel i mantenim l'audioManager
    @StateObject private var viewModel = AlbumDetailViewModel()
    @ObservedObject var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 30) {
                // COLUMNA ESQUERRA: Art i Info
                VStack(spacing: 20) {
                    if let coverId = album.coverArt, let url = SubsonicConfig().getCoverArtURL(id: coverId) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit)
                                    .frame(width: 350, height: 350).cornerRadius(12).shadow(radius: 10)
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                    .frame(width: 350, height: 350).cornerRadius(12)
                            }
                        }
                    }
                    Text(album.name).font(.title).bold().multilineTextAlignment(.center)
                    Text(album.artist).font(.title2).foregroundColor(.secondary)
                }
                .frame(width: 400).padding(.top, 20)
                
                // TRACKLIST
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(viewModel.songs) { song in
                            Button(action: {
                                if let index = viewModel.songs.firstIndex(where: { $0.id == song.id }) {
                                    audioManager.startPlayback(songs: viewModel.songs, fromIndex: index, inAlbum: album)
                                }
                            }) {
                                HStack {
                                    Text("\(song.track ?? 0)").frame(width: 35, alignment: .leading)
                                        .foregroundColor(audioManager.currentSong?.id == song.id ? .accentColor : .secondary)
                                    
                                    Text(song.title).font(.system(size: 16, weight: .medium))
                                        .foregroundColor(audioManager.currentSong?.id == song.id ? .accentColor : .primary)
                                    
                                    Spacer()
                                    
                                    if song.suffix?.lowercased() == "flac" {
                                        Text("FLAC").font(.caption2).bold().padding(4)
                                            .background(audioManager.currentSong?.id == song.id ? Color.accentColor : Color.gray.opacity(0.2))
                                            .foregroundColor(audioManager.currentSong?.id == song.id ? .white : .primary)
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(song.formattedDuration).monospacedDigit()
                                        .foregroundColor(audioManager.currentSong?.id == song.id ? .accentColor : .secondary)
                                }
                                .padding(.vertical, 12).padding(.horizontal, 15)
                                .background(audioManager.currentSong?.id == song.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                .contentShape(Rectangle())
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }.padding(20)
                }
            }
            // Aquí cridem a la variable que conté el reproductor de sota
            reproductorInferior
        }
        .onAppear {
            // 2. Cridem al ViewModel perquè carregui les dades de Nebraska
            viewModel.loadSongs(for: album.id)
        }
    }
    
    // AQUEST ÉS EL BLOC QUE FALTAVA (Actualitzat amb viewModel.songs)
    var reproductorInferior: some View {
        VStack(spacing: 0) {
            Divider()
            
            // NOU: BARRA DE PROGRÉS I TEMPS
            if audioManager.duration > 0 {
                HStack {
                    Text(formatTime(audioManager.currentTime)).font(.caption.monospacedDigit()).foregroundColor(.secondary)
                    ProgressView(value: audioManager.currentTime, total: audioManager.duration)
                        .tint(.accentColor)
                    Text(formatTime(audioManager.duration)).font(.caption.monospacedDigit()).foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
            }
            
            HStack(spacing: 25) {
                HStack(spacing: 15) {
                    Button(action: { audioManager.previousTrack() }) { Image(systemName: "backward.end.fill").font(.title2) }
                    Button(action: { audioManager.seek(seconds: -15) }) { Image(systemName: "gobackward.15").font(.title2) }
                    
                    Button(action: {
                        if audioManager.currentSong == nil && !viewModel.songs.isEmpty {
                            audioManager.startPlayback(songs: viewModel.songs, fromIndex: 0, inAlbum: album)
                        } else {
                            audioManager.togglePlayPause()
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill").font(.system(size: 50))
                    }
                    
                    Button(action: { audioManager.seek(seconds: 15) }) { Image(systemName: "goforward.15").font(.title2) }
                    Button(action: { audioManager.nextTrack() }) { Image(systemName: "forward.end.fill").font(.title2) }
                }
                .foregroundColor(.primary)
                
                VStack(alignment: .leading) {
                    Text(audioManager.currentSong?.title ?? "SocDel73 Player").font(.headline)
                    Text(audioManager.currentSong != nil ? album.artist : "Nebraska Streamer").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("BIT-PERFECT").font(.caption).bold()
                }.foregroundColor(.green).padding(8).background(Color.green.opacity(0.1)).cornerRadius(6)
            }
            .padding(.horizontal, 30).padding(.vertical, 15)
            .background(.regularMaterial)
        }
    }
    
    // Afegeix això abans de tancar el struct AlbumDetailView
    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
