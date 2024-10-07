import Foundation
import CoreData

class MacroEngine: ObservableObject {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    @Published var macroGroups: [MacroGroup] = []
    @Published var recentlyUsedMacros: [VersionedMacro] = []
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "KeySmith")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        context = container.viewContext
        
        fetchMacroGroups()
    }
    
    private func fetchMacroGroups() {
        let request: NSFetchRequest<MacroGroup> = MacroGroup.fetchRequest()
        do {
            macroGroups = try context.fetch(request)
        } catch {
            print("Error fetching macro groups: \(error)")
        }
    }
    
    func addMacroGroup(name: String) {
        let newGroup = MacroGroup(context: context)
        newGroup.id = UUID()
        newGroup.name = name
        
        do {
            try context.save()
            fetchMacroGroups()
        } catch {
            print("Error saving macro group: \(error)")
        }
    }
    
    func addMacro(name: String, to group: MacroGroup) {
        let newMacro = VersionedMacro(context: context)
        newMacro.id = UUID()
        newMacro.name = name
        newMacro.group = group
        
        let initialVersion = MacroVersion(context: context)
        initialVersion.id = UUID()
        initialVersion.timestamp = Date()
        initialVersion.name = "Initial Version"
        initialVersion.actions = []
        initialVersion.macro = newMacro
        
        do {
            try context.save()
            fetchMacroGroups()
        } catch {
            print("Error saving new macro: \(error)")
        }
    }
    
    func saveMacroVersion(_ macro: VersionedMacro, name: String, actions: [Action]) {
        let newVersion = MacroVersion(context: context)
        newVersion.id = UUID()
        newVersion.timestamp = Date()
        newVersion.name = name
        newVersion.actions = actions
        newVersion.macro = macro
        
        do {
            try context.save()
        } catch {
            print("Error saving macro version: \(error)")
        }
    }
    
    func loadMacroVersions(for macro: VersionedMacro) -> [MacroVersion] {
        let request: NSFetchRequest<MacroVersion> = MacroVersion.fetchRequest()
        request.predicate = NSPredicate(format: "macro == %@", macro)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MacroVersion.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching macro versions: \(error)")
            return []
        }
    }
    
    func runMacro(_ macro: VersionedMacro, in context: ContextManager) async throws {
        guard let latestVersion = loadMacroVersions(for: macro).first else {
            throw MacroError.noVersionFound
        }
        
        for action in latestVersion.actions {
            try await action.execute(in: MacroExecutionContext(parentContext: context))
        }
        
        updateRecentlyUsedMacros(macro)
    }
    
    private func updateRecentlyUsedMacros(_ macro: VersionedMacro) {
        if let index = recentlyUsedMacros.firstIndex(where: { $0.id == macro.id }) {
            recentlyUsedMacros.remove(at: index)
        }
        recentlyUsedMacros.insert(macro, at: 0)
        if recentlyUsedMacros.count > 5 {
            recentlyUsedMacros.removeLast()
        }
    }
}

enum MacroError: Error {
    case noVersionFound
    case executionError(String)
}
