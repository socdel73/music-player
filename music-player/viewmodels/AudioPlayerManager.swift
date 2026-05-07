import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    let engine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    @Published var currentSampleRate: Double = 0.0
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    
    private var queue: [Song] = []
    private var currentTrackIndex: Int = 0
    private var currentAudioFile: AVAudioFile?
    private var seekFrameOffset: AVAudioFramePosition = 0
    private var displayTimer: Timer?
    private var downloadTask: URLSessionDownloadTask?
    private var nextAudioFile: AVAudioFile?
    private var isPreloadingNext: Bool = false
    
    private init() {
        setupAudioSession()
        engine.attach(playerNode)
    }
    
    private func setupAudioSession() {
#if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("❌ Session Error") }
#endif
    }
    
    // MARK: - Controls
    func startPlayback(songs: [Song], fromIndex index: Int, inAlbum album: Album) {
        self.queue = songs
        self.playTrack(at: index)
    }
    
    func togglePlayPause() {
        if playerNode.isPlaying {
            playerNode.pause()
            isPlaying = false
        } else if currentAudioFile != nil {
            try? engine.start()
            playerNode.play()
            isPlaying = true
        }
    }
    
    func nextTrack() {
        displayTimer?.invalidate()
        playerNode.stop() // Aturem qualsevol resta de so
        
        if let nextFile = nextAudioFile {
            print("⏭️ Salt Gapless usant buffer pre-carregat")
            self.currentTrackIndex += 1
            let fileToPlay = nextFile
            self.nextAudioFile = nil
            playPreloadedFile(fileToPlay)
        } else {
            print("🔄 No hi ha pre-càrrega, descarregant normalment...")
            if currentTrackIndex + 1 < queue.count {
                playTrack(at: currentTrackIndex + 1)
            }
        }
    }
    
    func previousTrack() {
        if currentTrackIndex > 0 {
            playTrack(at: currentTrackIndex - 1)
        }
    }
    
    func seek(seconds: Double) {
        guard let file = currentAudioFile else { return }
        
        let wasPlaying = isPlaying
        playerNode.stop()
        
        let sr = file.processingFormat.sampleRate
        // Calculem la nova posició basada en l'offset actual + el salt de segons
        let targetFrame = max(0, min(seekFrameOffset + AVAudioFramePosition(seconds * sr), file.length))
        self.seekFrameOffset = targetFrame
        
        let framesToPlay = AVAudioFrameCount(file.length - targetFrame)
        
        if framesToPlay > 0 {
            playerNode.scheduleSegment(file, startingFrame: targetFrame, frameCount: framesToPlay, at: nil) { [weak self] in
                // Només saltem si el fitxer s'acaba realment
                DispatchQueue.main.async {
                    if self?.playerNode.isPlaying == false { self?.nextTrack() }
                }
            }
            if wasPlaying { playerNode.play() }
        } else {
            nextTrack()
        }
    }
    
    private func playTrack(at index: Int) {
        self.currentTrackIndex = index
        let song = queue[index]
        
        // --- NETEJA TOTAL (Antifauna) ---
        downloadTask?.cancel()        // Atura la descàrrega actual
        nextAudioFile = nil           // Buida el buffer pre-carregat de l'altre àlbum
        isPreloadingNext = false      // Reseteja el flag de control
        // --------------------------------
        
        DispatchQueue.main.async {
            self.currentSong = song
            self.isPlaying = false
            self.currentTime = 0
        }
        
        playerNode.stop()
        downloadTask?.cancel()
        
        guard let url = NavidromeService().getStreamURL(for: song.id) else { return }
        downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] url, _, _ in
            if let url = url { self?.prepareAndPlay(fileURL: url) }
        }
        downloadTask?.resume()
    }
    
    private func prepareAndPlay(fileURL: URL) {
        do {
            let file = try AVAudioFile(forReading: fileURL)
            self.currentAudioFile = file
            let format = file.processingFormat
            
            self.seekFrameOffset = 0 // IMPORTANT: Reset a 0 per cançó nova
            
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            engine.prepare()
            try engine.start()
            
            playerNode.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async { self?.nextTrack() }
            }
            
            playerNode.play()
            self.updateTelemetry()
            
            DispatchQueue.main.async {
                self.currentSong = self.queue[self.currentTrackIndex]
                self.currentSampleRate = format.sampleRate
                self.duration = Double(file.length) / format.sampleRate
                self.isPlaying = true
                self.startDisplayTimer()
                self.preloadNextTrack()
            }
        } catch { print("❌ Engine Error: \(error)") }
    }
    
    private func playPreloadedFile(_ file: AVAudioFile) {
        self.currentAudioFile = file
        let format = file.processingFormat
        self.seekFrameOffset = 0 // Reset per a la pre-carregada
        
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        engine.prepare()
        try? engine.start()
        
        playerNode.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async { self?.nextTrack() }
        }
        
        playerNode.play()
        self.updateTelemetry()
        
        DispatchQueue.main.async {
            self.currentSong = self.queue[self.currentTrackIndex]
            self.currentSampleRate = format.sampleRate
            self.duration = Double(file.length) / format.sampleRate
            self.isPlaying = true
            self.startDisplayTimer()
            self.preloadNextTrack()
        }
    }
    
    func preloadNextTrack() {
        let nextIndex = currentTrackIndex + 1
        guard nextIndex < queue.count, !isPreloadingNext else { return }
        
        isPreloadingNext = true
        let nextSong = queue[nextIndex]
        
        guard let url = NavidromeService().getStreamURL(for: nextSong.id) else {
            isPreloadingNext = false
            return
        }
        
        URLSession.shared.downloadTask(with: url) { [weak self] url, _, _ in
            guard let self = self, let url = url else {
                self?.isPreloadingNext = false
                return
            }
            
            do {
                let file = try AVAudioFile(forReading: url)
                self.nextAudioFile = file
                print("📦 Següent pista pre-carregada: \(nextSong.title)")
            } catch {
                print("❌ Error pre-carregant: \(error)")
            }
            self.isPreloadingNext = false
        }.resume()
    }
    
    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying,
                  let nodeTime = self.playerNode.lastRenderTime,
                  let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else { return }
            
            let absoluteFrame = self.seekFrameOffset + playerTime.sampleTime
            let calculatedTime = Double(absoluteFrame) / self.currentSampleRate
            
            DispatchQueue.main.async {
                if calculatedTime >= (self.duration - 0.1) { // Marge de seguretat
                    self.currentTime = self.duration
                    // Deixem que el scheduleFile s'encarregui del salt
                } else {
                    self.currentTime = calculatedTime
                }
            }
        }
    }
}
