import Foundation
import AVFoundation
import Combine // <-- AQUÍ TENIM LA CLAU MÀGICA

// 'ObservableObject' converteix aquesta classe en un transmissor de ràdio.
// Les vistes (pantalles) es podran subscriure per escoltar quan canvia la cançó.
class AudioPlayerManager: ObservableObject {
    
    // Creem un "Singleton". Una única instància global del motor per a tota l'app.
    // Com tenir un sol amplificador a casa on hi connectem tot.
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    
    // @Published vol dir que quan aquestes variables canviïn,
    // la interfície d'usuari s'actualitzarà automàticament!
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    
    private init() {
        // Configurem la sessió d'àudio del dispositiu perquè prioritzi la reproducció de mitjans (Premium)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Error configurant l'AVAudioSession: \(error)")
        }
    }
    
    /// Rep una cançó i la seva URL, i encén els fogons!
    func play(song: Song, url: URL) {
        // Si ja hi havia alguna cosa sonant, ho aturem
        player?.pause()
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        player?.play()
        
        // Actualitzem l'estat perquè la UI (el reproductor de baix) reaccioni
        self.currentSong = song
        self.isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
}

