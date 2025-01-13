//
//  Controller.swift
//  skeuomorphic-audio-recorder
//
//  Created by Iain McKenzie on 2025-01-12.
//

import Foundation
import AVFoundation

@MainActor class Controller: ObservableObject {
    @Published var isScaled = false
    @Published private(set) var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    
    func initializeAudio() {
        let recordingSession = AVAudioSession.sharedInstance()
                
        do {
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
                
            recordingSession.requestRecordPermission({ result in
                guard result else { return }
            })
        } catch {
            print("ERROR: Failed to set up recording session.")
        }
        
        if audioRecorder != nil { return }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    self.audioRecorder?.updateMeters()
                    if let db = self.audioRecorder?.averagePower(forChannel: 0) {
                        // calibration may vary by device
                        self.audioLevel = max(min(db + 40.0, 40), 0) / 40.0
                    }
                }
            }
        } catch {
            print("ERROR: Failed to set up audio recorder.")
        }
    }
    
    func start() {
        guard let ar = audioRecorder else {
            print("Audio recorder not ready yet.")
            return
        }
        
        ar.record()
        isRecording = true
    }
    
    func stop() {
        audioRecorder?.pause()
        isRecording = false
    }
    
    // convenience function
    func toggle() {
        if isRecording { stop() }
        else { start() }
    }
}
