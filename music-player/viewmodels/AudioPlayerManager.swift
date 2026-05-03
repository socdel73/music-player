// viewmodels/AudioPlayerManager.swift
import Foundation
import AVFoundation
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
    private var seekFrameOffset: AVAudioFramePosition = 0
    private var displayTimer: Timer?
    private var downloadTask: URLSessionDownloadTask?
    
    private init() {
        setupAudioSession()
        // Només l'adjuntem, NO el preparem ni l'arrenquem encara.
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
    
    func nextTrack() { if currentTrackIndex + 1 < queue.count { playTrack(at: currentTrackIndex + 1) } }
    func previousTrack() { if currentTrackIndex > 0 { playTrack(at: currentTrackIndex - 1) } }
    
    func seek(seconds: Double) {
        guard let file = currentAudioFile else { return }
        playerNode.stop()
        let sr = file.processingFormat.sampleRate
        let currentFrame = seekFrameOffset + (playerNode.lastRenderTime.flatMap { playerNode.playerTime(forNodeTime: $0)?.sampleTime } ?? 0)
        var target = currentFrame + AVAudioFramePosition(seconds * sr)
        target = max(0, min(target, file.length))
        self.seekFrameOffset = target
        
        let framesToPlay = AVAudioFrameCount(file.length - target)
        if framesToPlay > 0 {
            playerNode.scheduleSegment(file, startingFrame: target, frameCount: framesToPlay, at: nil)
            if isPlaying { playerNode.play() }
        }
    }
    
    private func playTrack(at index: Int) {
        self.currentTrackIndex = index
        let song = queue[index]
        DispatchQueue.main.async { self.currentSong = song; self.isPlaying = false }
        
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
            
            // CONNECTEM ARA (Just abans de sonar)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            engine.prepare()
            try engine.start()
            
            playerNode.scheduleFile(file, at: nil, completionHandler: nil)
            playerNode.play()
            
            DispatchQueue.main.async {
                self.currentSampleRate = format.sampleRate
                self.duration = Double(file.length) / format.sampleRate
                self.isPlaying = true
                self.startDisplayTimer()
            }
        } catch { print("❌ Engine Error: \(error)") }
    }
    
    // viewmodels/AudioPlayerManager.swift
    
    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying,
                  let nodeTime = self.playerNode.lastRenderTime,
                  let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else { return }
            
            let absoluteFrame = self.seekFrameOffset + playerTime.sampleTime
            let calculatedTime = Double(absoluteFrame) / self.currentSampleRate
            
            // CRITICAL: Sempre al fil principal per evitar l'error de "view updates"
            DispatchQueue.main.async {
                self.currentTime = calculatedTime
            }
        }
    }
}
