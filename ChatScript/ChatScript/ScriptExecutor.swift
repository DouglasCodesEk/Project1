import Foundation

class ScriptExecutor {
    enum ScriptExecutionError: Error, LocalizedError {
        case executionFailed(String)
        case compilationFailed(String)
        case savingFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .executionFailed(let message):
                return "Execution failed: \(message)"
            case .compilationFailed(let message):
                return "Compilation failed: \(message)"
            case .savingFailed(let message):
                return "Saving failed: \(message)"
            }
        }
    }
    
    static func execute(_ scriptString: String) -> Result<String, ScriptExecutionError> {
        let script = NSAppleScript(source: scriptString)
        var error: NSDictionary?
        let output = script?.executeAndReturnError(&error)
        
        if let error = error {
            return .failure(.executionFailed(error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"))
        } else {
            return .success(output?.stringValue ?? "No output")
        }
    }
    
    static func compileAndSave(_ scriptString: String, to url: URL) -> Result<Void, ScriptExecutionError> {
        let script = NSAppleScript(source: scriptString)
        var error: NSDictionary?
        
        guard let compiledScript = script?.compile(&error) else {
            return .failure(.compilationFailed(error?["NSAppleScriptErrorMessage"] as? String ?? "Failed to compile script"))
        }
        
        let success = compiledScript.write(to: url, ofType: "scpt", usingStorageOptions: .atomic, error: &error)
        
        if !success {
            return .failure(.savingFailed(error?["NSAppleScriptErrorMessage"] as? String ?? "Failed to save script"))
        }
        
        return .success(())
    }
}
