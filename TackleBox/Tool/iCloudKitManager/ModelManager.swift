import Combine
import Foundation
import SwiftData
import SwiftUI

/// ModelManager
///
/// 负责创建并管理应用的 `ModelContainer`，并在开启或切换同步策略（如 iCloud）时
/// 安全地迁移数据到目标 schema。此类封装了容器构建、迁移回退策略与版本化迁移
/// 的执行逻辑：
///
/// - 首先尝试使用当前（新）schema 创建 ModelContainer。
/// - 若失败（例如本地已有旧 schema），则尝试打开旧 schema 容器并基于已注册的
///   版本化迁移（MigrationRegistry）将旧数据迁移到新容器。
/// - 在 `updateContainer(useICloud:)` 中支持在运行时切换是否使用 iCloud，并进行相应迁移。
final class ModelManager: ObservableObject {
  let objectWillChange = ObservableObjectPublisher()
  @Published private(set) var container: ModelContainer
  private(set) var isUsingICloud: Bool

  /// 初始化 ModelManager
  ///
  /// - 读取用户配置决定是否启用 iCloud 同步
  /// - 优先尝试构造新 schema 的容器；若失败则尝试从 legacy schema 打开并迁移数据
  init() {
    let useICloud = UserDefaults.standard.bool(forKey: "useICloudSync")
    self.isUsingICloud = useICloud
    let schema = Schema([Equipment.self])
    do {
      // 尝试使用新 schema 创建容器（最常见的路径）
      self.container = try Self.makeContainer(schema: schema, useICloud: useICloud)
    } catch {
      // 如果新 schema 无法打开（可能本地已有旧 schema），尝试从 legacy 容器迁移
      do {
        let legacySchema = Schema([Equipment.self])
        let legacyContainer = try Self.makeContainer(schema: legacySchema, useICloud: useICloud)

        // 创建用于接收迁移后数据的新容器
        let newContainer = try Self.makeContainer(schema: schema, useICloud: useICloud)

        // 使用 MigrationRegistry 按版本化迁移策略执行迁移
        let oldContext = legacyContainer.mainContext
        let newContext = newContainer.mainContext
        try MigrationRegistry.applyPendingMigrations(oldContext: oldContext, newContext: newContext)

        // 将新容器设为当前容器
        self.container = newContainer
      } catch {
        // 若容器创建或迁移失败，抛出致命错误（可根据需要改为更温和的降级）
        fatalError("Could not create ModelContainer or migrate legacy data: \(error)")
      }
    }

    // 监听用户偏好变化以在运行时响应 iCloud 同步开关
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDefaultsChanged(_:)),
      name: UserDefaults.didChangeNotification,
      object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// 当用户偏好发生变化时触发（例如开关 iCloud 同步）
  @objc private func userDefaultsChanged(_ note: Notification) {
    let useICloud = UserDefaults.standard.bool(forKey: "useICloudSync")
    if useICloud != isUsingICloud {
      Task { @MainActor in
        await updateContainer(useICloud: useICloud)
      }
    }
  }

  /// 工厂方法：根据 schema 构造 `ModelContainer`。
  ///
  /// 说明：当前实现使用了默认 `ModelContainer(for:)`，若需要针对 CloudKit 做额外配置
  ///（如自定义 `ModelConfiguration`）可以在此处扩展。
  static func makeContainer(schema: Schema, useICloud: Bool) throws -> ModelContainer {
    return try ModelContainer(for: schema)
  }

  /// 在运行时更新容器（例如切换是否使用 iCloud），并在必要时迁移数据
  @MainActor
  func updateContainer(useICloud: Bool) async {
    let schema = Schema([Equipment.self])
    let oldContainer = self.container

    do {
      let newContainer = try Self.makeContainer(schema: schema, useICloud: useICloud)

      // 将旧容器的数据迁移到新容器，优先使用 MigrationRegistry（按版本执行迁移）
      let oldContext = oldContainer.mainContext
      let newContext = newContainer.mainContext

      try MigrationRegistry.applyPendingMigrations(oldContext: oldContext, newContext: newContext)

      // 迁移成功后将新的容器替换为当前容器并更新状态
      self.container = newContainer
      self.isUsingICloud = useICloud
    } catch {
      // 若迁移或容器创建失败，打印错误并恢复用户偏好
      print("Failed to update ModelContainer or migrate data: \(error)")
      UserDefaults.standard.set(self.isUsingICloud, forKey: "useICloudSync")
    }
  }
}
