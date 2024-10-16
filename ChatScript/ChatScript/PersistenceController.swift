import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: ScriptHistory.self, Variable.self, PresetScript.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
}
