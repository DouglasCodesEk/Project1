protocol SystemOperations {
    func executeAppleScript(_ script: String) -> String?
    func simulateKeyPress(_ key: String)
    func getClipboardContents() -> String
}

class MockSystemOperations: SystemOperations {
    func executeAppleScript(_ script: String) -> String? {
        print("Simulated AppleScript execution: \(script)")
        return "Mocked AppleScript result"
    }
    
    func simulateKeyPress(_ key: String) {
        print("Simulated key press: \(key)")
    }
    
    func getClipboardContents() -> String {
        return "Mocked clipboard contents"
    }
}

// In your actual implementation:
class RealSystemOperations: SystemOperations {
    // Implement real system operations here
    // These would use the actual system APIs when the app is running with proper permissions
}

// In your app's main structure:
struct KeySmithApp: App {
    @StateObject private var systemOps: SystemOperations = {
        #if DEBUG
        return MockSystemOperations()
        #else
        return RealSystemOperations()
        #endif
    }()
    
    // ... rest of the app structure
}
