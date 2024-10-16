// AIServiceError.swift

import Foundation

enum AIServiceError: Error, LocalizedError {
    case missingAPIKey
    case noData
    case decodingError
    case noResponse
    case invalidURL
    case networkError(Error)
    case unsupportedProvider
    case unknownError
    case custom(message: String) // If using custom error messages

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode the response."
        case .noResponse:
            return "No response received."
        case .invalidURL:
            return "The URL is invalid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unsupportedProvider:
            return "The selected AI provider is unsupported."
        case .unknownError:
            return "An unknown error occurred."
        case .custom(let message):
            return message
        }
    }
}
