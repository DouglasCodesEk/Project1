class LogManager {
    static let shared = LogManager()
    private var logEntries: [LogEntry] = []
    
    private init() {}
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let entry = LogEntry(message: message, level: level, file: file, function: function, line: line)
        logEntries.append(entry)
        print(entry.description)  // Print to console for immediate feedback
        
        // Save to file (implement this method)
        saveToFile(entry)
    }
    
    func getLog() -> String {
        return logEntries.map { $0.description }.joined(separator: "\n")
    }
    
    private func saveToFile(_ entry: LogEntry) {
        // Implement file saving logic here
    }
}

struct LogEntry {
    let timestamp: Date
    let message: String
    let level: LogLevel
    let file: String
    let function: String
    let line: Int
    
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: timestamp)
        return "[\(dateString)] [\(level.rawValue)] [\(file):\(line) \(function)] \(message)"
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}
