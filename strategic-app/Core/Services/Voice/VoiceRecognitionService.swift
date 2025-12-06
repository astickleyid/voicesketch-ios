//
//  VoiceRecognitionService.swift
//  VoiceSketch
//

import Foundation
import Speech
import AVFoundation

/// Voice recognition service using Apple's Speech framework
actor VoiceRecognitionService {
    private let logger = AppLogger(category: "VoiceRecognition")
    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    
    init() {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    /// Request speech recognition permissions
    func requestPermissions() async -> Bool {
        logger.info("Requesting permissions")
        
        // Request speech recognition
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        
        guard speechStatus else {
            logger.error("Speech recognition not authorized")
            return false
        }
        
        // Request microphone
        let micStatus = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        guard micStatus else {
            logger.error("Microphone not authorized")
            return false
        }
        
        logger.info("Permissions granted")
        return true
    }
    
    /// Start listening for voice input
    func startListening() async throws -> AsyncStream<String> {
        logger.info("Starting voice recognition")
        
        guard await requestPermissions() else {
            throw VoiceSketchError.voicePermissionDenied
        }
        
        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw VoiceSketchError.voiceRecognitionFailed
        }
        
        return AsyncStream { continuation in
            Task {
                do {
                    // Configure audio session
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                    
                    // Create recognition request
                    let request = SFSpeechAudioBufferRecognitionRequest()
                    request.shouldReportPartialResults = true
                    request.requiresOnDeviceRecognition = false // Use server for better accuracy
                    
                    self.request = request
                    
                    // Start recognition task
                    self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                        if let result = result {
                            let transcript = result.bestTranscription.formattedString
                            continuation.yield(transcript)
                            
                            if result.isFinal {
                                continuation.finish()
                            }
                        }
                        
                        if let error = error {
                            self?.logger.error("Recognition error", error: error)
                            continuation.finish()
                        }
                    }
                    
                    // Configure audio input
                    let inputNode = audioEngine.inputNode
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                        request.append(buffer)
                    }
                    
                    // Start audio engine
                    audioEngine.prepare()
                    try audioEngine.start()
                    
                    self.logger.info("Voice recognition active")
                    
                } catch {
                    self.logger.error("Failed to start recognition", error: error)
                    continuation.finish()
                }
            }
        }
    }
    
    /// Stop listening
    func stopListening() {
        logger.info("Stopping voice recognition")
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        request?.endAudio()
        task?.cancel()
        
        request = nil
        task = nil
    }
    
    /// Check if recognition is available
    func isAvailable() -> Bool {
        recognizer?.isAvailable ?? false
    }
}
