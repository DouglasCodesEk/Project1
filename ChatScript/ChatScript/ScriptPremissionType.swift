import Foundation

enum ScriptPermissionType: String, CaseIterable, Identifiable {
    case fileSystem = "File System"
    case network = "Network"
    case systemEvents = "System Events"
    case applicationInteraction = "Application Interaction"

    var id: String { self.rawValue }

    var bitValue: Int {
        switch self {
        case .fileSystem:
            return 1 << 0
        case .network:
            return 1 << 1
        case .systemEvents:
            return 1 << 2
        case .applicationInteraction:
            return 1 << 3
        }
    }
}
