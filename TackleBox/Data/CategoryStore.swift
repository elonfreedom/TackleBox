import Foundation
import Combine

final class CategoryStore: ObservableObject {
  static let shared = CategoryStore()

  @Published private(set) var categories: [Category] = []

  private let seedFlagKey = "com.tacklebox.didSeedCategories"
  private let storageKey = "com.tacklebox.presetCategories"

  private init() {
    load()
  }

  /// 在应用首次打开时写入预置分类（只执行一次）
  func seedIfNeeded() {
    let didSeed = UserDefaults.standard.bool(forKey: seedFlagKey)
    if didSeed { return }

    // 使用 UserDefaults + PropertyList 存储预置数据（避免使用 JSON 文件）
    let defaults = UserDefaults.standard
    do {
      try save(categories: Self.defaultCategories())
      categories = Self.defaultCategories()
      defaults.set(true, forKey: seedFlagKey)
    } catch {
      categories = Self.defaultCategories()
      print("Category seeding failed: \(error)")
    }
  }

  // MARK: - Persistence

  private func load() {
    let defaults = UserDefaults.standard
    if let data = defaults.data(forKey: storageKey) {
      do {
        let decoded = try PropertyListDecoder().decode([Category].self, from: data)
        categories = decoded
        return
      } catch {
        print("Failed to decode preset categories from UserDefaults: \(error)")
      }
    }

    categories = Self.defaultCategories()
  }

  private func save(categories: [Category]) throws {
    let encoder = PropertyListEncoder()
    let data = try encoder.encode(categories)
    UserDefaults.standard.set(data, forKey: storageKey)
  }

  // MARK: - Defaults

  private static func defaultCategories() -> [Category] {
    // 优先从 bundle 中的 DefaultCategories.plist 加载预置分类
    if let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "plist") {
      do {
        let data = try Data(contentsOf: url)
        let decoded = try PropertyListDecoder().decode([Category].self, from: data)
        return decoded
      } catch {
        print("Failed to load DefaultCategories.plist: \(error). Falling back to code defaults.")
        return []
      }
    }
    return []
  }
}
