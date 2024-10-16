import Foundation
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
