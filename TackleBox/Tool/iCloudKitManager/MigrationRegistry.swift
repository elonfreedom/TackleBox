import Foundation
import SwiftData

/// MigrationRegistry
///
/// 负责注册与执行按版本顺序的迁移操作，并在每次成功迁移后记录已应用的版本与时间戳。
///
/// 目的：
/// - 防止用户跨越多个发布版本直接升级造成的数据不一致或丢失。
/// - 以可审计的方式记录哪些迁移已执行，便于排查与回退。
///
/// 使用方式：
/// - 在 `migrations` 中按升序添加迁移项，每个迁移包含 `version`、`description` 和 `migrate` 闭包。
/// - `migrate` 闭包接收 `oldContext` 与 `newContext`，可使用 `MigrationHelper` 进行对象级复制或执行自定义逻辑。
/// - 系统会跳过已应用版本，只执行尚未应用的迁移，并在每次迁移成功后记录历史与更新最后应用版本号。
struct MigrationEntry: Codable {
  let version: Int
  let description: String
  let timestamp: Date
}

final class MigrationRegistry {
  // UserDefaults 存储键（轻量元数据）
  private static let versionKey = "com.tacklebox.migrationVersion"
  private static let historyKey = "com.tacklebox.migrationHistory"

  /// 在此处注册所有迁移，按 `version` 升序执行
  /// 每个迁移闭包在实际运行时会接收到源与目标的 `ModelContext`，便于读取与写入
  static var migrations:
    [(version: Int, description: String, migrate: (ModelContext, ModelContext) throws -> Void)]
  {
    return [
      // 未来新增迁移请在此追加：version 需严格递增
    ]
  }

  /// 获取最后已应用的迁移版本（默认 0）
  static func lastAppliedVersion() -> Int {
    return UserDefaults.standard.integer(forKey: versionKey)
  }

  /// 记录最后已应用的迁移版本
  static func setLastAppliedVersion(_ v: Int) {
    UserDefaults.standard.set(v, forKey: versionKey)
  }

  /// 将迁移条目追加到历史记录（以 JSON Data 数组存储）
  static func appendHistory(_ entry: MigrationEntry) {
    var arr: [Data] = UserDefaults.standard.array(forKey: historyKey) as? [Data] ?? []
    if let data = try? JSONEncoder().encode(entry) {
      arr.append(data)
      UserDefaults.standard.set(arr, forKey: historyKey)
    }
  }

  /// 执行所有尚未应用的迁移，按版本顺序执行；遇到错误会抛出，调用方需捕获并处理
  static func applyPendingMigrations(oldContext: ModelContext, newContext: ModelContext) throws {
    let last = lastAppliedVersion()
    for m in migrations.sorted(by: { $0.version < $1.version }) {
      if m.version <= last { continue }
      try m.migrate(oldContext, newContext)
      let entry = MigrationEntry(version: m.version, description: m.description, timestamp: Date())
      appendHistory(entry)
      setLastAppliedVersion(m.version)
    }
  }
}
