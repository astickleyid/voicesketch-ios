//
//  Logger.swift
//  VoiceSketch
//

import Foundation
import os.log

struct AppLogger {
    private let logger: Logger
    
    init(subsystem: String = Bundle.main.bundleIdentifier ?? "VoiceSketch", category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
    
    func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
    
    func warning(_ message: String) {
        logger.warning("\(message)")
    }
    
    func error(_ message: String, error: Error? = nil) {
        if let error = error {
            logger.error("\(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
}
