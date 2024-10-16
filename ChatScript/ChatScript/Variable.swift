import Foundation
import SwiftData

@Model
class Variable: Identifiable {
    var name: String
    var value: String

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
