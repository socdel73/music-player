// viewmodels/AudioPlayerManager.swift

import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    // MARK: - 1. El Core d'Alta Fidelitat (AVAudioEngine)
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    
    // NOU: El nostre sensor Bit-Perfect. Aquí llegirem la freqüència real de l'arxiu FLAC.
    @Published var currentSampleRate: Double = 0.0
    
    private var queue: [Song] = []
    private var currentAlbum: Album?
    private var currentTrackIndex: Int = 0
    // Variable per controlar la posició matemàtica de l'àudio
    private var currentAudioFile: AVAudioFile?
    // Control de sessions per evitar salts de cançó fantasmes
    private var playSessionId = UUID()
    
    // Telemetria de temps per a la UI
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    private var seekFrameOffset: AVAudioFramePosition = 0
    private var displayTimer: Timer?
    
    // Gestor de la descàrrega temporal
    private var downloadTask: URLSessionDownloadTask?
    
    private init() {
        setupAudioSession()
        setupEngine()
        setupRemoteCommandCenter()
    }
    
    // MARK: - 2. Configuració del Maquinari
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
        // Connectem el node de reproducció al mesclador principal del sistema
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("❌ Error iniciant AVAudioEngine: \(error)")
        }
    }
    
    // MARK: - 3. Gestió de la Reproducció
    func startPlayback(songs: [Song], fromIndex index: Int, inAlbum album: Album) {
        self.queue = songs
        self.currentAlbum = album
        playTrack(at: index)
    }
    
    private func playTrack(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        self.currentTrackIndex = index
        let song = queue[index]
        
        DispatchQueue.main.async {
            self.currentSong = song
            self.isPlaying = false
            self.currentSampleRate = 0.0 // Resetejem la lectura
        }
        
        // Aturem l'àudio actual i qualsevol descàrrega pendent
        playerNode.stop()
        downloadTask?.cancel()
        
        // Demanem la URL RAW a Nebraska
        guard let url = NavidromeService().getStreamURL(for: song.id) else { return }
        
        // Descarreguem l'arxiu sencer a la memòria cau per poder llegir els headers FLAC exactes
        downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self, let tempURL = tempURL, error == nil else {
                print("❌ Error descarregant el track: \(error?.localizedDescription ?? "Desconegut")")
                return
            }
            
            self.prepareAndPlay(fileURL: tempURL)
        }
        downloadTask?.resume()
    }
    
    // MARK: - 4. Decodificació Bit-Perfect
    // MARK: - 4. Decodificació Bit-Perfect
    private func prepareAndPlay(fileURL: URL) {
        do {
            // Llegim l'arxiu FLAC físicament
            let audioFile = try AVAudioFile(forReading: fileURL)
            self.currentAudioFile = audioFile
            let format = audioFile.processingFormat
            
            // LLEGIM LA QUALITAT REAL!
            let sampleRate = format.sampleRate
            
            // Guardem la durada total i reiniciem l'offset
            let totalSeconds = Double(audioFile.length) / sampleRate
            self.seekFrameOffset = 0
            
            // --- BLOC UI (Fil Principal) ---
            DispatchQueue.main.async {
                self.currentSampleRate = sampleRate
                self.duration = totalSeconds
                self.currentTime = 0
                print("🎧 Format Detectat: \(sampleRate / 1000) kHz")
            }
            
            // --- BLOC MOTOR DE SO (Fil de Fons) ---
            // Creem una nova sessió abans de reproduir
            let currentSession = UUID()
            self.playSessionId = currentSession
            
            // Programem l'arxiu al node i el reproduïm
            playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    // NOMÉS saltem de cançó si ningú ha interromput la sessió fent 'stop' o 'seek'
                    guard let self = self, self.playSessionId == currentSession else { return }
                    self.nextTrack()
                }
            }
            
            playerNode.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
                self.startDisplayTimer()
            }
            
        } catch {
            print("❌ Error llegint l'arxiu d'àudio: \(error)")
        }
    }
    // MARK: - 5. Controls
    func togglePlayPause() {
        if playerNode.isPlaying {
            playerNode.pause()
            isPlaying = false
        } else {
            playerNode.play()
            isPlaying = true
        }
    }
    
    func nextTrack() {
        if currentTrackIndex + 1 < queue.count {
            playTrack(at: currentTrackIndex + 1)
        } else {
            // Fi de l'àlbum
            DispatchQueue.main.async {
                self.isPlaying = false
                self.currentSong = nil
            }
        }
    }
    
    func previousTrack() {
        if currentTrackIndex > 0 {
            playTrack(at: currentTrackIndex - 1)
        }
    }
    
    func seek(seconds: Double) {
        guard let audioFile = currentAudioFile, playerNode.isPlaying else { return }
        
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else { return }
        
        // LA FIXACIÓ: Temps de la mostra actual + el punt on vam deixar anar l'agulla l'últim cop
        let absoluteCurrentFrame = self.seekFrameOffset + playerTime.sampleTime
        let currentAbsoluteTime = Double(absoluteCurrentFrame) / audioFile.processingFormat.sampleRate
        let newTime = currentAbsoluteTime + seconds
        
        let targetTime = max(0, min(newTime, self.duration))
        let targetFrame = AVAudioFramePosition(targetTime * audioFile.processingFormat.sampleRate)
        let remainingFrames = AVAudioFrameCount(audioFile.length - targetFrame)
        
        let newSession = UUID()
        self.playSessionId = newSession
        
        // Guardem on posem l'agulla per al proper càlcul!
        self.seekFrameOffset = targetFrame
        
        playerNode.stop()
        
        if remainingFrames > 0 {
            playerNode.scheduleSegment(audioFile, startingFrame: targetFrame, frameCount: remainingFrames, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self, self.playSessionId == newSession else { return }
                    self.nextTrack()
                }
            }
            playerNode.play()
        } else {
            nextTrack()
        }
    }
    // MARK: - 6. Sistema Operatiu (Lock Screen)
    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.togglePlayPause(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.togglePlayPause(); return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.nextTrack(); return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in self?.previousTrack(); return .success }
    }
    
    // MARK: - 7. Telemetria
    private func startDisplayTimer() {
        displayTimer?.invalidate() // Netegem timers antics
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying,
                  let nodeTime = self.playerNode.lastRenderTime,
                  let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else { return }
            
            let absoluteCurrentFrame = self.seekFrameOffset + playerTime.sampleTime
            let timeInSeconds = Double(absoluteCurrentFrame) / self.currentSampleRate
            
            DispatchQueue.main.async {
                self.currentTime = timeInSeconds
            }
        }
    }
}
