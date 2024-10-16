import Foundation
import Combine // Assuming you're using Combine for ObservableObject

class AIService: ObservableObject {
    @Published private(set) var provider: AIProvider
    let errorHandler = ErrorHandler()

    init(provider: AIProvider = .anthropicClaudeHaiku) {
        self.provider = provider
    }

    func setProvider(_ provider: AIProvider) {
        self.provider = provider
    }

    func generateScript(from input: String, completion: @escaping (Result<String, Error>) -> Void) {
        switch provider {
        case .anthropicClaudeHaiku:
            sendAnthropicRequest(prompt: input, completion: completion)
        case .openAIGPT3_5Turbo:
            sendOpenAIRequest(prompt: input, completion: completion)
        }
    }

    func generateScript(from input: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            generateScript(from: input) { result in
                switch result {
                case .success(let script):
                    continuation.resume(returning: script)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func sendOpenAIRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Existing OpenAI request implementation
    }
    
    private func sendAnthropicRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = KeychainHelper.getAPIKey(for: .anthropic), !apiKey.isEmpty else {
            completion(.failure(AIServiceError.missingAPIKey))
            Logger.shared.log("Missing Anthropic API Key.", level: .error)
            return
        }

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            completion(.failure(AIServiceError.invalidURL))
            Logger.shared.log("Invalid Anthropic URL.", level: .error)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        // Define the system prompt as a top-level parameter
        let systemPrompt = "You are an AI assistant that generates AppleScript code based on the user's description adding delays where necessary considering computer speed. Provide only the code in your response."

        // Define the user message using Codable structs
        let messages = [
            AnthropicMessage(
                role: "user",
                content: [
                    AnthropicContent(type: "text", text: prompt)
                ]
            )
        ]

        let requestBody = AnthropicRequest(
            model: provider.modelName,
            max_tokens: 632,
            temperature: 0,
            system: systemPrompt,
            messages: messages,
            stop_sequences: ["\n\nHuman:"]
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(requestBody)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                Logger.shared.log("Anthropic API Request JSON:\n\(jsonString)", level: .info)
            }
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            Logger.shared.log("Failed to serialize Anthropic request body: \(error.localizedDescription)", level: .error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AIServiceError.networkError(error)))
                Logger.shared.log("Anthropic network error: \(error.localizedDescription)", level: .error)
                return
            }

            guard let data = data else {
                completion(.failure(AIServiceError.noData))
                Logger.shared.log("No data received from Anthropic API.", level: .error)
                return
            }

            // Log raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                Logger.shared.log("Anthropic Raw Response: \(rawResponse)", level: .info)
            }

            do {
                let anthropicResponse = try JSONDecoder().decode(AnthropicMessageResponse.self, from: data)
                
                // Extract and concatenate all text content
                let scripts = anthropicResponse.content
                    .filter { $0.type == "text" }
                    .map { $0.text }
                
                let concatenatedScript = scripts.joined(separator: "\n")
                let parsedScript = self.parseResponse(concatenatedScript)
                
                Logger.shared.log("Parsed Script: \(parsedScript)", level: .info)
                completion(.success(parsedScript))
            } catch {
                completion(.failure(AIServiceError.decodingError))
                Logger.shared.log("Decoding error: \(error.localizedDescription)", level: .error)
            }
        }

        task.resume()
    }

    private func parseResponse(_ response: String) -> String {
        var script = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if script.hasPrefix("```") {
            script = script.components(separatedBy: "```").dropFirst().first ?? script
        }
        return script.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
