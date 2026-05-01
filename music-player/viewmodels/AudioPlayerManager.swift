import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    private var player: AVQueuePlayer?
    private var playerObservers: [AnyCancellable] = []
    
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    
    private var queue: [Song] = []
    private var currentAlbum: Album?
    
    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch { print("❌ Error Audio Session") }
    }
    
    func startPlayback(songs: [Song], fromIndex index: Int, inAlbum album: Album) {
        self.queue = songs
        self.currentAlbum = album
        
        player?.pause()
        player?.removeAllItems()
        
        // Creem els items per a la cua
        let items = songs.suffix(from: index).compactMap { song -> AVPlayerItem? in
            guard let url = NavidromeService().getStreamURL(for: song.id) else { return nil }
            return AVPlayerItem(url: url)
        }
        
        player = AVQueuePlayer(items: items)
        setupObservers()
        player?.play()
    }
    
    private func setupObservers() {
        playerObservers.removeAll()
        
        // Sincronització crítica: Escolta quan realment canvia l'item al motor
        player?.publisher(for: \.currentItem)
            .receive(on: RunLoop.main)
            .sink { [weak self] newItem in
                guard let self = self, let item = newItem else { return }
                self.syncWithCurrentItem(item)
            }
            .store(in: &playerObservers)
        
        player?.publisher(for: \.timeControlStatus)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.isPlaying = (status == .playing)
            }
            .store(in: &playerObservers)
    }
    
    private func syncWithCurrentItem(_ item: AVPlayerItem) {
        let asset = item.asset as? AVURLAsset
        let urlString = asset?.url.absoluteString
        
        // Busquem la cançó a la cua que coincideixi amb la URL
        if let foundSong = queue.first(where: { NavidromeService().getStreamURL(for: $0.id)?.absoluteString == urlString }) {
            DispatchQueue.main.async {
                self.currentSong = foundSong
                print("Sincronitzat amb: \(foundSong.title)")
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying { player?.pause() } else { player?.play() }
    }
    
    func nextTrack() {
        // AVQueuePlayer gestiona el salt internament, només li hem de dir que avanci
        player?.advanceToNextItem()
    }
    
    func previousTrack() {
        if let current = currentSong, let idx = queue.firstIndex(where: { $0.id == current.id }), idx > 0 {
            startPlayback(songs: queue, fromIndex: idx - 1, inAlbum: currentAlbum!)
        }
    }
    
    func seek(seconds: Double) {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: seconds, preferredTimescale: 1))
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.togglePlayPause(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.togglePlayPause(); return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.nextTrack(); return .success }
    }
}
