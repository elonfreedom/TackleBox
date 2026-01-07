import SwiftUI
import SwiftData
import ImageIO

struct ItemRow: View {
  let item: Equipment
  let viewModel: HomeViewModel
  let modelContext: ModelContext

  var body: some View {
    HStack {
      // Leading image: equipment image if model thumbnail exists,
      // otherwise fall back to the category default SF Symbol.
      let categoryIcon = CategoryStore.shared.categories.first(where: { $0.name == item.category })?.icon ?? "shippingbox"
      // 优先使用模型内的缩略图数据（如果存在），使用 ImageIO -> CGImage 来构建 SwiftUI Image（不依赖 UIKit）
      if let data = item.thumbnail, let cg = Self.cgImage(from: data) {
        Image(decorative: cg, scale: 1.0)
          .resizable()
          .scaledToFill()
          .frame(width: 44, height: 44)
          .background(Color(.tertiarySystemFill))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.separator), lineWidth: 0.5))
                    .padding()

      } else {
        Image(systemName: categoryIcon)
          .resizable()
          .scaledToFit()
          .frame(width: 44, height: 44)
          .foregroundColor(.accentColor)
          .background(Color(.tertiarySystemFill))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.separator), lineWidth: 0.5))
          .padding()
      }

      VStack(alignment: .leading) {
        Text(item.name)
          .font(.title3)
          .fontWeight(.semibold)

        HStack {
          // Text("×\(item.quantity)")
          //   .font(.subheadline)
            // .foregroundColor(.clear)

          Text(item.status)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor(for: item.status))
            .clipShape(Capsule())
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.secondary)
    }
    .padding()
    .frame(height: 80)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(8)
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
      return Color.gray
    }
  }
}

//struct ItemRow_Previews: PreviewProvider {
//  static var previews: some View {
//      ItemRow(item: <#Equipment#>, viewModel: <#HomeViewModel#>, modelContext: <#ModelContext#>)
//  }
//}
// Preview omitted due to ModelContext construction complexity in this environment.
