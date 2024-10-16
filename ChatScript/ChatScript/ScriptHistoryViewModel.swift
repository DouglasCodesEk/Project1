import SwiftUI
import SwiftData

@MainActor
class ScriptHistoryViewModel: ObservableObject {
    @Published var scripts: [ScriptHistory] = []
    @Published var selectedScript: ScriptHistory?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchScripts() async {
        let descriptor = FetchDescriptor<ScriptHistory>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            scripts = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch scripts: \(error)")
        }
    }

    func deleteScripts(at offsets: IndexSet) async {
        for index in offsets {
            let script = scripts[index]
            context.delete(script)
        }
        do {
            try context.save()
            await fetchScripts()
        } catch {
            print("Failed to delete scripts: \(error)")
        }
    }
}
