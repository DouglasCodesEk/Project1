//
//  Item.swift
//  MediaKeypad
//
//  Created by Admin on 2024-09-13.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
