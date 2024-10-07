import Foundation

enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError:
            return "Failed to decode the response from the server."
        case .missingAPIKey:
            return "API Key is missing. Please set your API key in the settings."
        }
    }
}

class AIService {
    private let provider: AIProvider

    init(provider: AIProvider) {
        self.provider = provider
    }

    func generateScript(from input: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Retrieve API key based on provider
        guard let apiKey = KeychainHelper.getAPIKey(for: provider) else {
            completion(.failure(AIServiceError.missingAPIKey))
            return
        }
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-4-turbo", // Ensure this is the correct model name
            "messages": [
                ["role": "system", "content": "You are an expert AppleScript generator. Generate only the AppleScript code without any explanations."],
                ["role": "user", "content": "Generate a functioning AppleScript for the following task. Only return the AppleScript code, nothing else: \(input)"]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(AIServiceError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    let script = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        completion(.success(script))
                    }
                } else {
                    throw AIServiceError.decodingError
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
