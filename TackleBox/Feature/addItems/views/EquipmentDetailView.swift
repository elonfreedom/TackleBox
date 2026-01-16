import SwiftUI
import SwiftData
import ImageIO

struct EquipmentDetailView: View {
  var item: Equipment
  @Environment(\.modelContext) private var modelContext

  @State private var isEditing: Bool = false
  @State private var showEditor: Bool = false
  @State private var name: String = ""
  @State private var category: String = ""
  @State private var quantityText: String = ""
  @State private var status: String = ""
  @State private var notes: String = ""
  @State private var attributesText: String = ""

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // Card container
        VStack(spacing: 16) {
          // Top image
          if let data = item.thumbnail, let cg = Self.cgImage(from: data) {
            Image(decorative: cg, scale: 1.0)
              .resizable()
              .scaledToFill()
              .frame(height: 200)
              .frame(maxWidth: .infinity)
              .clipped()
          } else {
            Rectangle()
              .fill(Color.surfaceColor)
              .frame(height: 200)
              .frame(maxWidth: .infinity)
          }

          // Title
          Group {
            if isEditing {
              TextField("名称", text: $name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            } else {
              Text(item.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            }
          }
          .foregroundColor(.white)
          .padding(.horizontal)

          Divider().background(Color.green.opacity(0.5))

          // Two-column attributes grid
          VStack(spacing: 0) {
            let attrs = parseAttributes() ?? [:]
            let leftPairs: [(String, String)] = [
              ("品牌", String(describing: attrs["brand"] ?? "-")),
              ("材质", String(describing: attrs["material"] ?? "-")),
              ("重量", String(describing: attrs["weight"] ?? item.quantity))
            ]
            let rightPairs: [(String, String)] = [
              ("型号", String(describing: attrs["model"] ?? "-")),
              ("长度", String(describing: attrs["length"] ?? "-")),
              ("价格", String(describing: attrs["price"] ?? "-"))
            ]

            ForEach(0..<max(leftPairs.count, rightPairs.count), id: \.self) { idx in
              HStack(alignment: .top) {
                // Left column
                VStack(alignment: .leading, spacing: 6) {
                  Text(leftPairs.indices.contains(idx) ? leftPairs[idx].0 : "")
                    .font(.subheadline)
                    .foregroundColor(Color.green.opacity(0.8))
                  Text(leftPairs.indices.contains(idx) ? leftPairs[idx].1 : "")
                    .font(.body)
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right column
                VStack(alignment: .leading, spacing: 6) {
                  Text(rightPairs.indices.contains(idx) ? rightPairs[idx].0 : "")
                    .font(.subheadline)
                    .foregroundColor(Color.green.opacity(0.8))
                  Text(rightPairs.indices.contains(idx) ? rightPairs[idx].1 : "")
                    .font(.body)
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .padding(.vertical, 12)

              if idx < max(leftPairs.count, rightPairs.count) - 1 {
                Divider().background(Color.green.opacity(0.4))
              }
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 16)

        }
        .background(Color.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(16)

        // Notes / attributes / edit area below card
        VStack(alignment: .leading, spacing: 12) {
          if isEditing {
            Text("备注")
              .font(.headline)
            TextEditor(text: $notes)
              .frame(minHeight: 80)
              .font(.body)
              .accessibilityIdentifier("EquipmentNotesEditor_\(item.id.uuidString)")

            Text("属性 (JSON)")
              .font(.headline)
            TextEditor(text: $attributesText)
              .frame(minHeight: 80)
              .font(.body)
              .accessibilityIdentifier("EquipmentAttributesEditor_\(item.id.uuidString)")
          } else if let notes = item.notes, !notes.isEmpty {
            Text("备注")
              .font(.headline)
            Text(notes)
              .font(.body)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)

        Spacer(minLength: 40)
      }
    }
    .navigationTitle("藏珍")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("编辑") { showEditor = true }
      }
      if isEditing {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("取消") { cancelEdit() }
        }
      }
    }
    .onAppear {
      // populate local editing state
      name = item.name
      category = item.category ?? ""
      quantityText = String(item.quantity)
      status = item.status
      notes = item.notes ?? ""
      attributesText = item.attributesJSON ?? ""
    }
    .appBackgrounded()
    .sheet(isPresented: $showEditor) {
      NavigationStack {
        AddItemView(editingItem: item)
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
  }

  private func saveChanges() {
    // apply edits back to the observed model
    item.name = name
    item.category = category.isEmpty ? nil : category
    if let q = Int(quantityText) { item.quantity = q }
    item.status = status
    item.notes = notes.isEmpty ? nil : notes
    item.attributesJSON = attributesText.isEmpty ? nil : attributesText

    do {
      try modelContext.save()
    } catch {
      // best-effort: ignore save errors for now
    }

    isEditing = false
  }

  private func cancelEdit() {
    // restore local fields from model
    name = item.name
    category = item.category ?? ""
    quantityText = String(item.quantity)
    status = item.status
    notes = item.notes ?? ""
    attributesText = item.attributesJSON ?? ""
    isEditing = false
  }

  private func enterEditMode() {
    isEditing = true
  }

  private func parseAttributes() -> [String: Any]? {
    guard let json = item.attributesJSON, let data = json.data(using: .utf8) else { return nil }
    do {
      let obj = try JSONSerialization.jsonObject(with: data, options: [])
      return obj as? [String: Any]
    } catch {
      return nil
    }
  }

  private static func cgImage(from data: Data) -> CGImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
  }

  private static let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
  }()
}

// SwiftData model classes are reference types; Preview omitted.

struct EquipmentDetailView_Previews: PreviewProvider {
  static var sample: Equipment {
    let e = Equipment(name: "预览鱼竿", category: "竿", timestamp: Date(), isEquipped: false, thumbnail: nil)
    e.quantity = 2
    e.status = "在用"
    e.notes = "这是一个用于预览的示例备注。"
    e.attributesJSON = "{\"length\": 2.4, \"material\": \"碳素\"}"
    return e
  }

  static var previews: some View {
    NavigationStack {
      EquipmentDetailView(item: sample)
    }
    .previewDisplayName("Equipment Detail - Preview")
  }
}
