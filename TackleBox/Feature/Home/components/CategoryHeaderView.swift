import SwiftUI

struct CategoryHeaderView: View {
  let categories: [String]
  @Binding var selectedIndex: Int

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Array(categories.enumerated()), id: \.offset) { index, title in
          let isSelected = (selectedIndex == index)
          Button(action: { selectedIndex = index }) {
            Text(title)
                  .font(.system(size: 14, weight: .medium))
              .foregroundColor(isSelected ? Color.onPrimaryColor : Color.textPrimaryColor)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(
                Capsule()
                  .fill(Color.surfaceColor))
          }
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
    }
    .listRowInsets(EdgeInsets())
    .background(Color.clear)
  }
}
