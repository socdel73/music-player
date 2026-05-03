import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    @Published var currentSampleRate: Double = 0.0
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    
    private var queue: [Song] = []
    private var currentTrackIndex: Int = 0
    private var currentAudioFile: AVAudioFile?
    private var playSessionId = UUID()
    private var seekFrameOffset: AVAudioFramePosition = 0
    private var displayTimer: Timer?
    private var downloadTask: URLSessionDownloadTask?
    
    private init() {
        setupAudioSession()
        setupEngine()
        setupRemoteCommandCenter()
    }
    
    private func setupAudioSession() {
#if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch { print("❌ Error Audio Session: \(error)") }
#endif
    }
    
    private func setupEngine() {
        engine.attach(playerNode)
        // No fem el start() aquí per evitar el crash si no hi ha connexions llestes.
        engine.prepare()
    }
    
    func startPlayback(songs: [Song], fromIndex index: Int, inAlbum album: Album) {
        self.queue = songs
        playTrack(at: index)
    }
    
    private func playTrack(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        self.currentTrackIndex = index
        let song = queue[index]
        
        DispatchQueue.main.async {
            self.currentSong = song
            self.isPlaying = false
        }
        
        playerNode.stop()
        downloadTask?.cancel()
        
        guard let url = NavidromeService().getStreamURL(for: song.id) else { return }
        
        downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            guard let self = self, let tempURL = tempURL, error == nil else { return }
            self.prepareAndPlay(fileURL: tempURL)
        }
        downloadTask?.resume()
    }
    
    private func prepareAndPlay(fileURL: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            self.currentAudioFile = audioFile
            let format = audioFile.processingFormat
            
            // Re-connexió dinàmica Bit-Perfect
            engine.disconnectNodeOutput(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            
            // Arrencada segura
            if !engine.isRunning { try engine.start() }
            
            let totalSeconds = Double(audioFile.length) / format.sampleRate
            self.seekFrameOffset = 0
            let currentSession = UUID()
            self.playSessionId = currentSession
            
            playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self, self.playSessionId == currentSession else { return }
                    self.nextTrack()
                }
            }
            
            playerNode.play()
            
            DispatchQueue.main.async {
                self.currentSampleRate = format.sampleRate
                self.duration = totalSeconds
                self.isPlaying = true
                self.startDisplayTimer()
            }
        } catch { print("❌ Error Motor: \(error)") }
    }
    
    func nextTrack() { if currentTrackIndex + 1 < queue.count { playTrack(at: currentTrackIndex + 1) } }
    
    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying,
                  let nodeTime = self.playerNode.lastRenderTime,
                  let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else { return }
            let absoluteFrame = self.seekFrameOffset + playerTime.sampleTime
            DispatchQueue.main.async { self.currentTime = Double(absoluteFrame) / self.currentSampleRate }
        }
    }
    
    private func setupRemoteCommandCenter() { /* Implementació MPNowPlayingInfoCenter */ }
}
