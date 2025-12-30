import Foundation
import Combine
import SwiftData

final class HomeViewModel: ObservableObject {
  func delete(at offsets: IndexSet, items: [Item], context: ModelContext) {
    for index in offsets {
      let item = items[index]
      context.delete(item)
    }

    do {
      try context.save()
    } catch {
      print("Delete error: \(error)")
    }
  }

  func toggleEquip(item: Item, context: ModelContext) {
    item.isEquipped.toggle()
    do {
      try context.save()
    } catch {
      print("Toggle error: \(error)")
    }
  }
}
