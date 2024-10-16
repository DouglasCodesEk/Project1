// AnthropicMessageResponse.swift

import Foundation

struct AnthropicMessageResponse: Decodable {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [AnthropicContent]
    let stop_reason: String?
    let stop_sequence: String?
    let usage: Usage
}

struct Usage: Decodable {
    let input_tokens: Int
    let output_tokens: Int
}
