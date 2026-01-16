import SwiftUI

private struct AppBackgroundKey: EnvironmentKey {
  static let defaultValue: Color = Color.white
}

extension EnvironmentValues {
  var appBackground: Color {
    get { self[AppBackgroundKey.self] }
    set { self[AppBackgroundKey.self] = newValue }
  }
}

fileprivate struct AppBackgroundModifier: ViewModifier {
  @Environment(\.appBackground) private var bg
  func body(content: Content) -> some View {
    ZStack {
      bg.ignoresSafeArea()
      content
    }
  }
}

extension View {
  /// Apply the environment-provided app background behind this view.
  func appBackgrounded() -> some View {
    modifier(AppBackgroundModifier())
  }

  /// Helper to set the background color for this subtree via the environment.
  func appBackground(_ color: Color) -> some View {
    environment(\.appBackground, color)
  }
}
