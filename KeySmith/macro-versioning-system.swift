import Foundation

struct MacroVersion: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let actions: [Action]
    let name: String
}

class VersionedMacro: Identifiable, ObservableObject {
    let id: UUID
    @Published var currentVersion: MacroVersion
    var versions: [MacroVersion]
    
    init(id: UUID = UUID(), name: String, actions: [Action]) {
        self.id = id
        self.currentVersion = MacroVersion(id: UUID(), timestamp: Date(), actions: actions, name: name)
        self.versions = [self.currentVersion]
    }
    
    func createNewVersion(name: String? = nil, actions: [Action]? = nil) {
        let newVersion = MacroVersion(
            id: UUID(),
            timestamp: Date(),
            actions: actions ?? currentVersion.actions,
            name: name ?? currentVersion.name
        )
        versions.append(newVersion)
        currentVersion = newVersion
    }
    
    func rollbackTo(version: MacroVersion) {
        guard let index = versions.firstIndex(where: { $0.id == version.id }) else { return }
        currentVersion = versions[index]
    }
}

extension MacroEngine {
    func saveMacroVersion(_ macro: VersionedMacro) {
        // TODO: Implement saving to persistent storage
    }
    
    func loadMacroVersions(for macroID: UUID) -> VersionedMacro? {
        // TODO: Implement loading from persistent storage
        return nil
    }
}

struct MacroHistoryView: View {
    @ObservedObject var versionedMacro: VersionedMacro
    
    var body: some View {
        List(versionedMacro.versions) { version in
            HStack {
                Text(version.name)
                Spacer()
                Text(version.timestamp, style: .date)
                if version.id == versionedMacro.currentVersion.id {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Button("Revert") {
                        versionedMacro.rollbackTo(version: version)
                    }
                }
            }
        }
    }
}
