import SwiftUI
import SwiftData

@Model
class ScriptHistory: Identifiable {
    var id: UUID
    var content: String
    var createdAt: Date
    var name: String
    
    init(content: String, name: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.name = name
    }
}

@Model
class Variable: Identifiable {
    var id: UUID
    var name: String
    var value: String
    
    init(name: String, value: String) {
        self.id = UUID()
        self.name = name
        self.value = value
    }
}

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func saveScript(_ content: String, name: String, context: ModelContext) -> Result<Void, Error> {
        let script = ScriptHistory(content: content, name: name)
        context.insert(script)
        
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func getScriptHistory(context: ModelContext) -> Result<[ScriptHistory], Error> {
        let descriptor = FetchDescriptor<ScriptHistory>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        
        do {
            let scripts = try context.fetch(descriptor)
            return .success(scripts)
        } catch {
            return .failure(error)
        }
    }
    
    func saveVariable(_ name: String, value: String, context: ModelContext) -> Result<Void, Error> {
        let variable = Variable(name: name, value: value)
        context.insert(variable)
        
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func getVariables(context: ModelContext) -> Result<[Variable], Error> {
        let descriptor = FetchDescriptor<Variable>(sortBy: [SortDescriptor(\.name)])
        
        do {
            let variables = try context.fetch(descriptor)
            return .success(variables)
        } catch {
            return .failure(error)
        }
    }
}
