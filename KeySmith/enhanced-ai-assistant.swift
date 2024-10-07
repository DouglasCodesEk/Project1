import Foundation
import NaturalLanguage

class AIAssistant: ObservableObject {
    private let tagger: NLTagger
    
    init() {
        tagger = NLTagger(tagSchemes: [.lexicalClass])
    }
    
    func analyzeMacro(_ macro: VersionedMacro) -> [Suggestion] {
        var suggestions: [Suggestion] = []
        
        // Analyze macro name
        suggestions.append(contentsOf: analyzeMacroName(macro.name))
        
        // Analyze actions
        if let latestVersion = macro.versions?.allObjects.first as? MacroVersion {
            suggestions.append(contentsOf: analyzeActions(latestVersion.actions))
        }
        
        return suggestions
    }
    
    private func analyzeMacroName(_ name: String) -> [Suggestion] {
        var suggestions: [Suggestion] = []
        
        tagger.string = name
        let tags = tagger.tags(in: name.startIndex..<name.endIndex, unit: .word, scheme: .lexicalClass, options: [.omitWhitespace, .omitPunctuation])
        
        if tags.contains(where: { $0.0 == .verb }) {
            suggestions.append(Suggestion(type: .improvement, message: "Consider using a noun phrase for the macro name instead of a verb."))
        }
        
        if name.count < 3 {
            suggestions.append(Suggestion(type: .warning, message: "The macro name is very short. Consider using a more descriptive name."))
        }
        
        return suggestions
    }
    
    private func analyzeActions(_ actions: [Action]) -> [Suggestion] {
        var suggestions: [Suggestion] = []
        
        if actions.isEmpty {
            suggestions.append(Suggestion(type: .warning, message: "This macro doesn't have any actions. Add some actions to make it functional."))
        }
        
        if actions.count > 20 {
            suggestions.append(Suggestion(type: .improvement, message: "This macro has a large number of actions. Consider breaking it into smaller, more focused macros."))
        }
        
        if actions.filter({ $0 is DelayAction }).count > actions.count / 3 {
            suggestions.append(Suggestion(type: .improvement, message: "This macro uses many delay actions. Consider optimizing to reduce unnecessary waiting times."))
        }
        
        // Add more action analysis here...
        
        return suggestions
    }
    
    func provideTroubleshooting(for error: Error) -> String {
        switch error {
        case MacroError.noVersionFound:
            return "No versions found for this macro. Try creating a new version or checking if the macro was properly saved."
        case MacroError.executionError(let message):
            return "An error occurred during macro execution: \(message). Check if all required applications or files are available and try again."
        case is KeystrokeAction.KeystrokeError:
            return "There was an issue with a keystroke action. Ensure the target application is active and responsive."
        // Add more error cases and troubleshooting advice...
        default:
            return "An unexpected error occurred. Please check your macro configuration and try again. If the problem persists, consider reporting this issue."
        }
    }
}

struct Suggestion {
    enum SuggestionType {
        case improvement
        case warning
        case error
    }
    
    let type: SuggestionType
    let message: String
}
