protocol Action {
    func execute(in context: MacroExecutionContext) async throws
}

struct Macro: Identifiable {
    let id: UUID
    var name: String
    var triggers: [MacroTrigger]
    var actions: [Action]
    var contextConditions: MacroContextConditions?
    
    func shouldRunInContext(_ context: ContextManager) -> Bool {
        guard let conditions = contextConditions else { return true }
        return conditions.matches(context)
    }
}

// Update existing action types to conform to the new Action protocol
struct KeystrokeAction: Action {
    let key: String
    
    func execute(in context: MacroExecutionContext) async throws {
        // Implement keystroke logic
    }
}

struct DelayAction: Action {
    let duration: TimeInterval
    
    func execute(in context: MacroExecutionContext) async throws {
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
