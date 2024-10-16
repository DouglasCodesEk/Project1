// ScriptExecutionError.swift
import Foundation

enum ScriptExecutionError: Error, LocalizedError {
    case compilationFailed(String)
    case executionFailed(String)
    case savingFailed(String)

    var errorDescription: String? {
        switch self {
        case .compilationFailed(let message):
            return "Compilation failed: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        case .savingFailed(let message):
            return "Saving failed: \(message)"
        }
    }
}
