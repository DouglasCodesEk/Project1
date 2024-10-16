import Foundation
import SwiftData

@Model
class PresetScript: Identifiable, ObservableObject {
    var id: UUID
    var name: String
    var category: String
    var content: String

    init(id: UUID = UUID(), name: String, category: String, content: String) {
        self.id = id
        self.name = name
        self.category = category
        self.content = content
    }
}
