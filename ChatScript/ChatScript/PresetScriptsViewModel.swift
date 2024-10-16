import SwiftUI
import SwiftData

@MainActor
class PresetScriptsViewModel: ObservableObject {
    @Published var categories: [String] = []
    @Published var presetScripts: [PresetScript] = []
    @Published var errorMessage: String? = nil

    var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
    }

    func fetchPresetScripts() {
        guard let context = context else { return }
        do {
            presetScripts = try context.fetch(FetchDescriptor<PresetScript>())
            fetchCategories()
        } catch {
            errorMessage = "Failed to fetch scripts: \(error.localizedDescription)"
        }
    }

    func fetchCategories() {
        categories = Array(Set(presetScripts.map { $0.category })).sorted()
    }

    func removeCategory(_ category: String) {
        guard let context = context else { return }
        let scriptsToRemove = presetScripts.filter { $0.category == category }
        for script in scriptsToRemove {
            context.delete(script)
        }
        do {
            try context.save()
            presetScripts.removeAll { $0.category == category }
            categories.removeAll { $0 == category }
        } catch {
            errorMessage = "Failed to remove category: \(error.localizedDescription)"
        }
    }

    func addScript(name: String, content: String, category: String) {
        guard let context = context else { return }
        let newScript = PresetScript(name: name, category: category, content: content)
        context.insert(newScript)
        do {
            try context.save()
            fetchPresetScripts()
        } catch {
            errorMessage = "Failed to add script: \(error.localizedDescription)"
        }
    }
}
