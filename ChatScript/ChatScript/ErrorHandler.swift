// ErrorHandler.swift

import Foundation

class ErrorHandler {
    func handleError(_ error: Error) -> String {
        if let aiError = error as? AIServiceError {
            return aiError.localizedDescription
        }
        return error.localizedDescription
    }
}
