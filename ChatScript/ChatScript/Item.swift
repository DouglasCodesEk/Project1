import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    var id: UUID
    var timestamp: Date
    
    init(timestamp: Date) {
        self.id = UUID()
        self.timestamp = timestamp
    }
}
