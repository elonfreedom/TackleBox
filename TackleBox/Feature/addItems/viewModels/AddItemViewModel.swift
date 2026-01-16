import Foundation
import Combine
import SwiftData

final class AddItemViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var category: String = CategoryStore.shared.categories.first?.name ?? "" {
        didSet {
            // reset attribute values for newly selected category
            attributeValues = [:]
            if let attrs = selectedCategory?.attributes {
                for a in attrs { attributeValues[a.key] = "" }
            }
        }
    }
    @Published var quantity: Int = 1
    @Published var status: String = "在用"
    @Published var notes: String = ""

    // attribute key -> string value (store as JSON in Item)
    @Published var attributeValues: [String: String] = [:]

    let categories = CategoryStore.shared.categories
    let statuses = ["在用", "闲置", "损坏"]

    var selectedCategory: Category? {
        categories.first { $0.name == category }
    }

    init() {
        // initialize default attributes for first category
        if let attrs = selectedCategory?.attributes {
            for a in attrs { attributeValues[a.key] = "" }
        }
    }

    func save(context: ModelContext, existing: Equipment? = nil) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // If updating an existing item, mutate its properties; otherwise create+insert
        if let existing = existing {
            existing.name = trimmed
            existing.category = category
            existing.quantity = max(1, quantity)
            existing.status = status
            existing.notes = notes.isEmpty ? nil : notes

            if !attributeValues.isEmpty {
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(attributeValues)
                    if let json = String(data: data, encoding: .utf8) {
                        existing.attributesJSON = json
                    }
                } catch {
                    print("Attribute JSON encode error: \(error)")
                }
            } else {
                existing.attributesJSON = nil
            }

            do {
                try context.save()
                return true
            } catch {
                print("Update save error: \(error)")
                return false
            }
        } else {
            let item = Equipment(name: trimmed, category: category)
            item.quantity = max(1, quantity)
            item.status = status
            item.notes = notes.isEmpty ? nil : notes

            if !attributeValues.isEmpty {
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(attributeValues)
                    if let json = String(data: data, encoding: .utf8) {
                        item.attributesJSON = json
                    }
                } catch {
                    print("Attribute JSON encode error: \(error)")
                }
            }

            context.insert(item)
            do {
                try context.save()
                return true
            } catch {
                print("AddItem save error: \(error)")
                return false
            }
        }
    }
}
