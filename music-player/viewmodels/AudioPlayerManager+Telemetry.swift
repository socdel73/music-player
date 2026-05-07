// viewmodels/AudioPlayerManager+Telemetry.swift
import Foundation
import AVFoundation

extension AudioPlayerManager {
    
    /// Actualitza la informació técnica real des del motor de so.
    /// Això és el que ens confirma si el so és Bit-Perfect.
    func updateTelemetry() {
        // Obtenim el format directament del node de sortida del motor
        let format = engine.outputNode.outputFormat(forBus: 0)
        
        // El Sample Rate real (ex: 44100.0, 96000.0)
        let sampleRate = format.sampleRate
        
        // Intentem extreure el Bit Depth (profunditat de bits)
        // Nota: AVAudioEngine sol processar internament a Float32,
        // però aquí busquem el format de la font.
        let bitDepth = format.settings[AVLinearPCMBitDepthKey] as? Int ?? 16
        
        DispatchQueue.main.async {
            self.currentSampleRate = sampleRate
            // Podries afegir una propietat @Published var currentBitDepth: Int si vols mostrar-ho a la UI
            print("📡 Telemetria: \(sampleRate / 1000)kHz | \(bitDepth)bit")
        }
    }
}
