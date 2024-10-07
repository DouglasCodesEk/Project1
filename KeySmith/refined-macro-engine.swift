import Foundation

class MacroEngine: ObservableObject {
    @Published var macroGroups: [MacroGroup] = []
    @Published var recentlyUsedMacros: [Macro] = []
    private var logger = Logger(subsystem: "com.keysmith", category: "MacroEngine")
    
    func addMacroGroup() {
        let newGroup = MacroGroup(name: "New Group", macros: [])
        macroGroups.append(newGroup)
    }
    
    func addMacro(_ macro: Macro, to group: MacroGroup) {
        if let index = macroGroups.firstIndex(where: { $0.id == group.id }) {
            macroGroups[index].macros.append(macro)
        }
    }
    
    func runMacro(_ macro: Macro, in context: ContextManager) async throws {
        guard macro.shouldRunInContext(context) else {
            logger.info("Macro \(macro.name) skipped due to context mismatch")
            return
        }
        
        logger.info("Starting execution of macro: \(macro.name)")
        let executionContext = MacroExecutionContext(parentContext: context)
        
        do {
            for action in macro.actions {
                try await executeAction(action, in: executionContext)
            }
            logger.info("Macro \(macro.name) executed successfully")
            updateRecentlyUsedMacros(macro)
        } catch {
            logger.error("Error executing macro \(macro.name): \(error.localizedDescription)")
            throw error
        }
    }
    
    private func executeAction(_ action: Action, in context: MacroExecutionContext) async throws {
        switch action {
        case let keystroke as KeystrokeAction:
            try await executeKeystroke(keystroke, in: context)
        case let delay as DelayAction:
            try await executeDelay(delay)
        case let conditional as ConditionalAction:
            try await executeConditional(conditional, in: context)
        case let nestedMacro as NestedMacroAction:
            try await executeNestedMacro(nestedMacro, in: context)
        default:
            throw MacroError.unsupportedAction
        }
    }
    
    private func executeKeystroke(_ action: KeystrokeAction, in context: MacroExecutionContext) async throws {
        logger.debug("Executing keystroke: \(action.key)")
        // Implement keystroke logic here
    }
    
    private func executeDelay(_ action: DelayAction) async throws {
        logger.debug("Executing delay: \(action.duration) seconds")
        try await Task.sleep(nanoseconds: UInt64(action.duration * 1_000_000_000))
    }
    
    private func executeConditional(_ action: ConditionalAction, in context: MacroExecutionContext) async throws {
        if try await action.condition.evaluate(in: context) {
            for action in action.ifTrue {
                try await executeAction(action, in: context)
            }
        } else if let elseBranch = action.ifFalse {
            for action in elseBranch {
                try await executeAction(action, in: context)
            }
        }
    }
    
    private func executeNestedMacro(_ action: NestedMacroAction, in context: MacroExecutionContext) async throws {
        guard let nestedMacro = findMacro(withID: action.macroID) else {
            throw MacroError.macroNotFound
        }
        try await runMacro(nestedMacro, in: context.parentContext)
    }
    
    private func findMacro(withID id: UUID) -> Macro? {
        for group in macroGroups {
            if let macro = group.macros.first(where: { $0.id == id }) {
                return macro
            }
        }
        return nil
    }
    
    private func updateRecentlyUsedMacros(_ macro: Macro) {
        if let index = recentlyUsedMacros.firstIndex(where: { $0.id == macro.id }) {
            recentlyUsedMacros.remove(at: index)
        }
        recentlyUsedMacros.insert(macro, at: 0)
        if recentlyUsedMacros.count > 5 {
            recentlyUsedMacros.removeLast()
        }
    }
}

struct MacroExecutionContext {
    let parentContext: ContextManager
    var variables: [String: Any] = [:]
}

enum MacroError: Error {
    case unsupportedAction
    case macroNotFound
    case executionError(String)
}

protocol Condition {
    func evaluate(in context: MacroExecutionContext) async throws -> Bool
}

struct ConditionalAction: Action {
    let condition: Condition
    let ifTrue: [Action]
    let ifFalse: [Action]?
}

struct NestedMacroAction: Action {
    let macroID: UUID
}
