import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case openAIGPT3_5Turbo = "OpenAI GPT-3.5 Turbo"
    case anthropicClaudeHaiku = "Anthropic Claude 3 Haiku"

    var id: String { self.rawValue }

    var modelName: String {
        switch self {
        case .openAIGPT3_5Turbo:
            return "gpt-3.5-turbo"
        case .anthropicClaudeHaiku:
            return "claude-3-haiku-20240307"
        }
    }

    var isOpenAI: Bool {
        self == .openAIGPT3_5Turbo
    }

    var isAnthropic: Bool {
        self == .anthropicClaudeHaiku
    }
}
