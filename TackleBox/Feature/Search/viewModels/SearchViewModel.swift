//
//  SearchViewModel.swift
//  TackleBox
//
//  Created by GitHub Copilot on 2025/12/30.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

//@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String
    @Published private(set) var items: [Item] = []

    private var modelContext: ModelContext?

    init(searchText: String = "") {
        self.query = searchText
    }

    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    func loadItems() {
        guard let ctx = modelContext else { items = []; return }
        let request = FetchDescriptor<Item>(sortBy: [SortDescriptor(\Item.name)])
        do {
            items = try ctx.fetch(request)
        } catch {
            items = []
        }
    }

    var filteredItems: [Item] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(q) || (item.category?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }

    func toggleEquipped(_ item: Item) {
        guard let ctx = modelContext else { return }
        withAnimation {
            item.isEquipped.toggle()
            do {
                try ctx.save()
                loadItems()
            } catch {
                item.isEquipped.toggle()
            }
        }
    }
}
