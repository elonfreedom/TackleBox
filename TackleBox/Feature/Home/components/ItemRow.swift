import SwiftUI
import SwiftData
import ImageIO

struct ItemRow: View {
  let item: Equipment
  let viewModel: HomeViewModel
  let modelContext: ModelContext
  let onTap: (() -> Void)?

  var body: some View {
    Group {
      rowContent
        .contentShape(Rectangle())
        .onTapGesture {
          onTap?()
        }
        .modifier(AccessibilityButtonTrait(if: onTap != nil))
    }
  }

  @ViewBuilder
  private var rowContent: some View {
    HStack {
      // Leading image: equipment image if model thumbnail exists,
      // otherwise fall back to the category default SF Symbol.
      let categoryIcon = CategoryStore.shared.categories.first(where: { $0.name == item.category })?.icon ?? "shippingbox"
      // 优先使用模型内的缩略图数据（如果存在），使用 ImageIO -> CGImage 来构建 SwiftUI Image（不依赖 UIKit）
      if let data = item.thumbnail, let cg = Self.cgImage(from: data) {
        Image(decorative: cg, scale: 1.0)
          .resizable()
          .scaledToFill()
          .frame(width: 60, height: 60)
          .background(Color.surfaceColor)
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .padding()

      } else {
        Image(systemName: categoryIcon)
          .resizable()
          .scaledToFit()
          .frame(width: 60, height: 60)
          .foregroundColor(.accentColor)
          .background(Color.surfaceColor)
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .padding()
      }
      VStack(alignment: .leading) {
        Text(item.name)
          .font(.title3)
          .fontWeight(.semibold)
      }
      Spacer()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12, style: .circular)
        .fill(Color.backgroundElevatedColor)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(item.name)
    .accessibilityValue(String(format: "数量 %d, 状态 %@, 分类 %@", item.quantity, item.status as CVarArg, (item.category ?? "未分类") as CVarArg))
    .accessibilityIdentifier("ItemRow_\(item.id.uuidString)")
  }

  

  private static func cgImage(from data: Data) -> CGImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
  }

  private func statusColor(for status: String) -> Color {
    switch status {
    case "在用":
      return Color(red: 0.09, green: 0.56, blue: 0.46)
    case "闲置":
      return Color(red: 0.20, green: 0.34, blue: 0.34)
    case "损坏":
      return Color(red: 0.53, green: 0.16, blue: 0.18)
    default:
      return Color.disabledColor
    }
  }
}

// Helper modifier to conditionally add the .isButton accessibility trait
fileprivate struct AccessibilityButtonTrait: ViewModifier {
  let `if`: Bool
  func body(content: Content) -> some View {
    if `if` {
      content.accessibilityAddTraits(.isButton)
    } else {
      content
    }
  }
}

//struct ItemRow_Previews: PreviewProvider {
//  static var previews: some View {
//      ItemRow(item: <#Equipment#>, viewModel: <#HomeViewModel#>, modelContext: <#ModelContext#>)
//  }
//}
// Preview omitted due to ModelContext construction complexity in this environment.
