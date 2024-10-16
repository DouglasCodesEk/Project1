// AIServiceModelView.swift

import SwiftUI
import Combine

@MainActor
class AIServiceModelView: ObservableObject {
    @Published var userInput: String = ""
    @Published var scriptOutput: String = ""
    @Published var executionResult: String = ""
    @Published var isLoading: Bool = false
    @Published var isExecuting: Bool = false
    @Published var errorMessage: String?

    var aiService: AIService

    init() {
        let selectedProvider: AIProvider = {
            if let providerRawValue = UserDefaults.standard.string(forKey: "SelectedAIProvider"),
               let provider = AIProvider(rawValue: providerRawValue) {
                return provider
            } else {
                return .anthropicClaudeHaiku // Default provider
            }
        }()

        self.aiService = AIService(provider: selectedProvider)
    }

    func generateScript() async {
        guard !userInput.isEmpty else {
            errorMessage = "Please enter a prompt."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let script = try await aiService.generateScript(from: userInput)
            scriptOutput = script
        } catch let error as AIServiceError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func executeScript(with permissions: ScriptPermission) async {
        guard !scriptOutput.isEmpty else {
            errorMessage = "No script to execute."
            return
        }
        isExecuting = true
        errorMessage = nil
        do {
            let executor = ScriptExecutor()
            let output = try await executor.executeSandboxed(scriptOutput, permissions: permissions)
            executionResult = output
        } catch let error as ScriptExecutionError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isExecuting = false
    }
}
