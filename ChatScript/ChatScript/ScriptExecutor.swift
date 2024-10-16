import Foundation
import AppKit

class ScriptExecutor {
    func execute(script: String) throws -> String {
        var errorDict: NSDictionary?
        let appleScript = NSAppleScript(source: script)

        guard let output = appleScript?.executeAndReturnError(&errorDict) else {
            if let errorDict = errorDict, let errorMessage = errorDict[NSLocalizedDescriptionKey] as? String {
                throw ScriptExecutionError.executionFailed(errorMessage)
            } else {
                throw ScriptExecutionError.executionFailed("Unknown error occurred during script execution.")
            }
        }

        return output.stringValue ?? "Script executed successfully."
    }

    func executeSandboxed(_ scriptString: String, permissions: ScriptPermission) async throws -> String {
        let scriptSandbox = try ScriptSandbox()
        return try scriptSandbox.executeScript(scriptString, permissions: permissions)
    }
}
