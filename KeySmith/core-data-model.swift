// MacroGroup.swift
import Foundation
import CoreData

@objc(MacroGroup)
public class MacroGroup: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var macros: NSSet?
}

// VersionedMacro.swift
@objc(VersionedMacro)
public class VersionedMacro: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var group: MacroGroup?
    @NSManaged public var versions: NSSet?
}

// MacroVersion.swift
@objc(MacroVersion)
public class MacroVersion: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var name: String
    @NSManaged public var actionData: Data
    @NSManaged public var macro: VersionedMacro?
    
    var actions: [Action] {
        get {
            return (try? JSONDecoder().decode([AnyAction].self, from: actionData)) ?? []
        }
        set {
            actionData = (try? JSONEncoder().encode(newValue.map(AnyAction.init))) ?? Data()
        }
    }
}

// AnyAction.swift
struct AnyAction: Codable, Action {
    private let type: String
    private let data: Data
    
    init(_ action: Action) {
        self.type = String(describing: type(of: action))
        self.data = try! JSONEncoder().encode(action)
    }
    
    func execute(in context: MacroExecutionContext) async throws {
        let action = try decodeAction()
        try await action.execute(in: context)
    }
    
    private func decodeAction() throws -> Action {
        switch type {
        case String(describing: KeystrokeAction.self):
            return try JSONDecoder().decode(KeystrokeAction.self, from: data)
        case String(describing: MouseMoveAction.self):
            return try JSONDecoder().decode(MouseMoveAction.self, from: data)
        case String(describing: MouseClickAction.self):
            return try JSONDecoder().decode(MouseClickAction.self, from: data)
        case String(describing: ClipboardAction.self):
            return try JSONDecoder().decode(ClipboardAction.self, from: data)
        case String(describing: DelayAction.self):
            return try JSONDecoder().decode(DelayAction.self, from: data)
        case String(describing: SystemCommandAction.self):
            return try JSONDecoder().decode(SystemCommandAction.self, from: data)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown action type"))
        }
    }
}
