import SwiftUI

struct CategoryHeaderView: View {
  let categories: [String]
  @Binding var selectedIndex: Int

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Array(categories.enumerated()), id: \.offset) { index, title in
          Button(action: { selectedIndex = index }) {
            Text(title)
              .font(.system(size: 14, weight: .semibold))
              .foregroundColor(selectedIndex == index ? Color.black : Color.white)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(
                Group {
                  if selectedIndex == index {
                    Capsule()
                      .fill(Color.accentColor)
                      .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                  } else {
                    Capsule()
                      .fill(Color.gray)
                      .overlay(
                        Capsule().stroke(Color.white.opacity(0.06), lineWidth: 1)
                      )
                  }
                }
              )
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
