// AnthropicRequest.swift

import Foundation

struct AnthropicRequest: Codable {
    let model: String
    let max_tokens: Int
    let temperature: Int
    let system: String
    let messages: [AnthropicMessage]
    let stop_sequences: [String]
}

struct AnthropicMessage: Codable {
    let role: String
    let content: [AnthropicContent]
}
