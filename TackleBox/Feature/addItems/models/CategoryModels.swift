import Foundation

enum AttributeType: String, Codable {
  case text
  case number
  case picker
}

struct AttributeDefinition: Codable, Identifiable {
  var id: String { key }
  let key: String
  let label: String
  let type: AttributeType
  let options: [String]?
}

struct Category: Codable, Identifiable {
  var id: String { name }
  let name: String
  let attributes: [AttributeDefinition]
  let icon: String
}

// 注意：预置分类将由首次启动时的种子方法创建并持久化。
// 不再在此处硬编码 `all` 常量。
