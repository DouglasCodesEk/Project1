import Foundation

class ScriptSandbox {
    private let fileManager = FileManager.default
    private let sandboxURL: URL

    init() throws {
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
        sandboxURL = appSupportURL.appendingPathComponent("ScriptSandbox")
        try fileManager.createDirectory(at: sandboxURL, withIntermediateDirectories: true, attributes: nil)
    }

    func executeScript(_ script: String, permissions: ScriptPermission) throws -> String {
        let sandboxedScript = try applySandboxing(to: script, with: permissions)

        let tempScriptURL = sandboxURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("scpt")
        try sandboxedScript.write(to: tempScriptURL, atomically: true, encoding: .utf8)

        defer {
            try? fileManager.removeItem(at: tempScriptURL)
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = [tempScriptURL.path]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        try task.run()
        task.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""

        return output
    }

    private func applySandboxing(to script: String, with permissions: ScriptPermission) throws -> String {
        var sandboxedScript = script

        for permissionType in ScriptPermissionType.allCases {
            let permission = ScriptPermission(permissionType: permissionType)
            if !permissions.contains(permission) {
                sandboxedScript = try disableFeature(for: permissionType, in: sandboxedScript)
            }
        }

        return sandboxedScript
    }

    private func disableFeature(for permissionType: ScriptPermissionType, in script: String) throws -> String {
        return """
        on run
            display dialog "This script requires \(permissionType.rawValue) permission."
        end run

        \(script)
        """
    }
}
