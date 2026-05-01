import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @State private var songs: [Song] = []
    
    // Ens connectem al preamplificador central
    @ObservedObject var audioManager = AudioPlayerManager.shared
    
    var body: some View {
        // L'edifici principal que conté tot el disseny
        VStack(spacing: 0) {
            
            // MARK: - PLANTA SUPERIOR (Caràtula Esquerra / Pistes Dreta)
            HStack(alignment: .top, spacing: 30) {
                
                // 📍 COLUMNA ESQUERRA: La Caràtula
                VStack(spacing: 20) {
                    if let coverId = album.coverArt, let url = NavidromeService().getCoverArtURL(coverId: coverId) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(width: 350, height: 350)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 350, height: 350)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                            case .failure:
                                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 350, height: 350).cornerRadius(12)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 350, height: 350).cornerRadius(12)
                    }
                    
                    // Informació de l'Àlbum sota la caràtula
                    VStack(spacing: 8) {
                        Text(album.name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text(album.artist)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 400) // Donem una amplada fixa a la columna esquerra
                .padding(.top, 20)
                
                // 📍 COLUMNA DRETA: El Tracklist
                // Canviem el "List" per un "ScrollView" per tenir un disseny més net i personalitzat
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TRACKLIST")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                        
                        if songs.isEmpty {
                            Text("Esperant el senyal de Nebraska...")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(songs) { song in
                                                        // Embolcallem l'HStack amb un Button!
                                                        Button(action: {
                                                            // QUAN FEM CLIC: Generem la URL i l'enviem al motor!
                                                            if let streamUrl = NavidromeService().getStreamURL(for: song.id) {
                                                                audioManager.play(song: song, url: streamUrl)
                                                            }
                                                        }) {
                                                            HStack {
                                                                // ... [El mateix codi que ja tenies per pintar la pista: text, format, temps] ...
                                                                Text("\(song.track ?? 0)").frame(width: 30, alignment: .leading).foregroundColor(.secondary)
                                                                Text(song.title).font(.system(size: 16, weight: .medium))
                                                                Spacer()
                                                                if let format = song.suffix {
                                                                    Text(format.uppercased()).font(.caption2).fontWeight(.bold).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 2).background(Color.accentColor.opacity(0.8)).cornerRadius(4)
                                                                }
                                                                Text(song.formattedDuration).foregroundColor(.secondary).monospacedDigit().frame(width: 50, alignment: .trailing)
                                                            }
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 10)
                                                            // Efecte visual de "pista seleccionada"
                                                            .background(audioManager.currentSong?.id == song.id ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.05))
                                                            .cornerRadius(8)
                                                        }
                                                        // Això evita que el botó es vegi com un text blau estàndard
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
            }
            
            Spacer() // Empenyem el reproductor cap a baix de tot
            
            // MARK: - PLANTA BAIXA: El Reproductor d'Àudio (Simulació)
            VStack(spacing: 0) {
                Divider() // Una línia fina per separar
                
                HStack(spacing: 30) {
                    // Botons de control (Simulats de moment)
                    // Botons de control
                                        HStack(spacing: 25) {
                                            Image(systemName: "backward.fill").font(.title2)
                                            
                                            // Botó Play/Pause dinàmic!
                                            Button(action: {
                                                audioManager.togglePlayPause()
                                            }) {
                                                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                                    .font(.largeTitle)
                                            }
                                            
                                            Image(systemName: "forward.fill").font(.title2)
                                        }
                                        .foregroundColor(.primary)
                                        
                                        // La pista que "sona" REAL!
                                        VStack(alignment: .leading) {
                                            Text(audioManager.currentSong?.title ?? "Preparat per reproduir...")
                                                .font(.headline)
                                                .lineLimit(1)
                                            Text(audioManager.currentSong != nil ? album.artist : "Motor de so inactiu")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                    
                    Spacer()
                    
                    // Simulació de qualitat
                    HStack(spacing: 4) {
                        Image(systemName: "hifispeaker.fill")
                        Text("BIT-PERFECT")
                            .font(.caption)
                            .bold()
                    }
                    .foregroundColor(.green)
                    .padding(.trailing, 20)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                // Un fons gris molt suau per a la barra del reproductor
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            NavidromeService().fetchTracks(for: album.id) { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedSongs) = result {
                        self.songs = fetchedSongs
                    }
                }
            }
        }
    }
}
