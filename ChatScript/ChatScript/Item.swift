//
//  CustomItem.swift
//  ChatScript
//
//  Created by Admin on 2024-10-07.
//


//
//  CustomItem.swift
//  ChatScript
//
//  Created by Admin on 2024-10-06.
//

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
