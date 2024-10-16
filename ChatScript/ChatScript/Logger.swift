// Logger.swift

import Foundation

class Logger {
    static let shared = Logger()
    
    let logFileURL: URL
    
    private init() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            logFileURL = documentsURL.appendingPathComponent("ChatScriptLog.txt")
        } else {
            logFileURL = fileManager.temporaryDirectory.appendingPathComponent("ChatScriptLog.txt")
        }
    }
    
    /// Logs a message with a specified log level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level of the log (default is `.info`).
    func log(_ message: String, level: LogLevel = .info) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fullMessage = "[\(timestamp)] \(level.rawValue.uppercased()): \(message)\n"
        
        // Write to log file
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                if let data = fullMessage.data(using: .utf8) {
                    fileHandle.write(data)
                }
            }
        } else {
            try? fullMessage.write(to: logFileURL, atomically: true, encoding: .utf8)
        }
        
        // Print to console
        print(fullMessage.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    /// Retrieves the current logs as a single string.
    /// - Returns: The contents of the log file, or `nil` if it cannot be read.
    func getLogs() -> String? {
        return try? String(contentsOf: logFileURL, encoding: .utf8)
    }
    
    // Convenience methods for different log levels
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func debug(_ message: String) {
        log(message, level: .debug)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
}
