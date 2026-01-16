import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: [SortDescriptor(\Equipment.timestamp, order: .reverse)]) private var items:
    [Equipment]
  @StateObject private var viewModel = HomeViewModel()
  @State private var showingAddItem = false
  @State private var selectedCategoryIndex: Int = 0
  @State private var path = NavigationPath()
  private let categories: [String] = {
    var cats = ["全部"]
    cats.append(contentsOf: CategoryStore.shared.categories.map { $0.name })
    return cats
  }()

  init() {}

  private var filteredItems: [Equipment] {
    if selectedCategoryIndex == 0 { return items }
    let selected = categories[selectedCategoryIndex]
    return items.filter { $0.category == selected }
  }

  var body: some View {
    NavigationStack(path: $path) {
      List {
        Section(
          header: CategoryHeaderView(categories: categories, selectedIndex: $selectedCategoryIndex)
        ) {
          ForEach(filteredItems, id: \.id) { item in
            ItemRow(item: item, viewModel: viewModel, modelContext: modelContext, onTap: { path.append(item) })
              .padding(.horizontal, 16)
              .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
          }
          .onDelete { offsets in
            viewModel.delete(at: offsets, items: filteredItems, context: modelContext)
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .appBackgrounded()
      .navigationTitle("装备")
      .navigationDestination(for: Equipment.self) { EquipmentDetailView(item: $0) }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { showingAddItem = true }) {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddItem) {
        NavigationStack {
          AddItemView()
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
