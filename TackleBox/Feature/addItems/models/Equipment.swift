//
//  Equipment.swift
//  TackleBox
//
//  Created by elonfreedom on 2025/12/6.
//

import Foundation
import SwiftData

@Model
final class Equipment {
    // Provide default values at property declaration so the underlying
    // Core Data attributes have defaults (required for CloudKit integration).
    var id: UUID = UUID()
    var name: String = ""
    var category: String? = nil
    var timestamp: Date = Date()
    var isEquipped: Bool = false
    var quantity: Int = 1
    var status: String = "在用"
    var notes: String? = nil
    // JSON-encoded arbitrary attributes per category (e.g. length, diameter)
    var attributesJSON: String? = nil
    // Optional thumbnail image data (e.g. JPEG/PNG) for list previews
    var thumbnail: Data? = nil

    init(id: UUID = UUID(), name: String, category: String? = nil, timestamp: Date = Date(), isEquipped: Bool = false, thumbnail: Data? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.timestamp = timestamp
        self.isEquipped = isEquipped
        self.thumbnail = thumbnail
    }
}
