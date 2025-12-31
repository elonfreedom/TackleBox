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
}

// Built-in categories
extension Category {
  static let all: [Category] = [
    Category(name: "鱼竿", attributes: [
      AttributeDefinition(key: "length", label: "长度 (m)", type: .number, options: nil),
      AttributeDefinition(key: "stiffness", label: "软硬度", type: .picker, options: ["软","中","硬"]) 
    ]),

    Category(name: "线组", attributes: [
      AttributeDefinition(key: "diameter", label: "线径 (mm)", type: .number, options: nil),
      AttributeDefinition(key: "length", label: "长度 (m)", type: .number, options: nil)
    ]),

    Category(name: "子线", attributes: [
      AttributeDefinition(key: "hook", label: "钩子型号", type: .text, options: nil),
      AttributeDefinition(key: "diameter", label: "线径 (mm)", type: .number, options: nil)
    ]),

    Category(name: "配件", attributes: []),
    Category(name: "工具", attributes: [])
  ]
}
