import Foundation
import SwiftData

/// MigrationHelper
///
/// 一个通用的迁移工具，负责把旧模型实例批量读取并通过用户提供的映射闭包
/// 转换为新模型实例后写入目标 `ModelContext`。适用于在应用升级或 schema
/// 变更时执行数据迁移的常见场景。
///
/// 设计要点：
/// - 泛型实现：对任意旧模型 `Old` 和新模型 `New` 都适用。
/// - 去重：会尝试读取目标上下文中已存在对象的 `id`（若类型遵循 `Identifiable` 且 `id` 为 UUID），
///   避免重复插入相同主键的数据。
/// - 变换闭包：由调用者提供，将单个 `Old` 映射为一个 `New` 实例，调用者负责字段映射与兼容性处理。
/// - 错误传播：读取或保存失败会向上抛出，调用方可捕获并处理回滚/上报逻辑。
@MainActor
final class MigrationHelper {
  /// 将 `oldContext` 中的所有 `Old` 实例迁移为在 `newContext` 中插入的 `New` 实例。
  ///
  /// - Parameters:
  ///   - oldType: 旧模型类型（例如 `LegacyItem.self`）
  ///   - newType: 新模型类型（例如 `Equipment.self`）
  ///   - oldContext: 源 `ModelContext`（从中读取旧数据）
  ///   - newContext: 目标 `ModelContext`（向其插入新实例并保存）
  ///   - transform: 将单个 `Old` 转换为 `New` 的闭包；此闭包应自行构造 `New` 实例并填充字段。
  ///
  /// - Important:
  ///   - 迁移过程中会尽量基于 `Identifiable.id` 做去重检测；如果无法获取 `id`，则会直接插入新实例，可能造成重复。
  ///   - 此函数会在完成插入操作后调用 `newContext.save()`，若希望更精细地控制保存策略，可先读取并手动调用保存。
  static func migrate<Old: PersistentModel, New: PersistentModel>(
    _ oldType: Old.Type,
    to newType: New.Type,
    from oldContext: ModelContext,
    to newContext: ModelContext,
    transform: (Old) -> New
  ) throws {
    // 从旧上下文读取所有旧对象
    let fetch = FetchDescriptor<Old>()
    let oldItems = try oldContext.fetch(fetch)

    // 读取目标上下文中已有的新对象，以 UUID id 做去重
    let existingFetch = FetchDescriptor<New>()
    let existingNewItems = (try? newContext.fetch(existingFetch)) ?? []
    let existingIDs = Set(
      existingNewItems.compactMap { item in
        // 如果 New 实现了 Identifiable 并且其 id 为 UUID，则用于去重检测
        (item as? any Identifiable)?.id as? UUID
      })

    for old in oldItems {
      // 读取旧对象的 id（若实现 Identifiable），用于判断是否已迁移
      let oldID = (old as? any Identifiable)?.id as? UUID
      if let id = oldID, existingIDs.contains(id) {
        continue
      }

      // 使用调用者提供的闭包构造新对象并插入
      let newObj = transform(old)
      newContext.insert(newObj)
    }

    // 将更改持久化到目标上下文
    try newContext.save()
  }
}
