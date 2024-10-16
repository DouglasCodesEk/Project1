import Foundation

struct ScriptPermission: OptionSet, CustomStringConvertible, Hashable {
    let rawValue: Int

    static let fileSystem = ScriptPermission(rawValue: ScriptPermissionType.fileSystem.bitValue)
    static let network = ScriptPermission(rawValue: ScriptPermissionType.network.bitValue)
    static let systemEvents = ScriptPermission(rawValue: ScriptPermissionType.systemEvents.bitValue)
    static let applicationInteraction = ScriptPermission(rawValue: ScriptPermissionType.applicationInteraction.bitValue)

    var description: String {
        let permissions = ScriptPermissionType.allCases.filter { self.contains(ScriptPermission(permissionType: $0)) }
        return permissions.map { $0.rawValue }.joined(separator: ", ")
    }

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(permissionType: ScriptPermissionType) {
        self.init(rawValue: permissionType.bitValue)
    }

    func toPermissionTypes() -> [ScriptPermissionType] {
        return ScriptPermissionType.allCases.filter { self.contains(ScriptPermission(permissionType: $0)) }
    }
}
