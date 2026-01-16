import SwiftUI

struct SettingsView: View {
  @StateObject private var viewModel = SettingsViewModel()

  var body: some View {
    NavigationStack {
      List {
        ForEach(viewModel.sections) { section in
          Section(section.title) {
            ForEach(section.items) { item in
              rowView(for: item)
            }
          }
        }
      }
      .background(Color.clear)
      .listStyle(.insetGrouped)
      .scrollContentBackground(.hidden)
      .appBackgrounded()
      .listRowBackground(Color.clear)
    }
    //    .appBackgrounded()
    .navigationTitle("设置")
    .navigationBarTitleDisplayMode(.large)
    .alert("iCloud 未登录", isPresented: $viewModel.showICloudUnavailableAlert) {
      Button("确定", role: .cancel) {}
    } message: {
      Text("请在设备设置中登录 iCloud 后再启用同步。")
    }
  }

  // Helper to reduce expression complexity for the Swift type checker
  private func rowView(for item: SettingsItem) -> AnyView {
    switch item.style {
    case .navigation:
      // match the iCloud row by its title from the ViewModel's sections
      if item.title == "iCloud 同步" {
        return AnyView(
          NavigationLink(destination: CloudSyncDetailView(viewModel: viewModel)) {
            SettingRow(title: item.title, subtitle: item.subtitle, trailingText: item.trailingText)
          }
        )
      } else {
        let trailingImage = item.trailingImageName.map { Image(systemName: $0) }
        return AnyView(
          NavigationLink(destination: Text(item.title)) {
            SettingRow(title: item.title, subtitle: item.subtitle, trailingImage: trailingImage)
          }
        )
      }

    case .toggle:
      let binding: Binding<Bool> = Binding(
        get: { item.toggleGet?() ?? false },
        set: { newValue in
          item.toggleSet?(newValue)
        })
      return AnyView(ToggleRow(title: item.title, subtitle: item.subtitle, isOn: binding))

    case .plain:
      let trailingImage = item.trailingImageName.map { Image(systemName: $0) }
      return AnyView(
        SettingRow(
          title: item.title, subtitle: item.subtitle, trailingText: item.trailingText,
          trailingImage: trailingImage))
    }
  }
}

// MARK: - Components

private struct SectionCard<Content: View>: View {
  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .fontWeight(.bold)
        .foregroundColor(.primaryColor)
        .padding([.top, .horizontal])

      content
        .padding(.horizontal)
        .padding(.bottom)
    }
    //    .background(Color.backgroundElevatedColor)
    .cornerRadius(14)
    .padding(.horizontal)
  }
}

private struct SettingRow: View {
  let title: String
  var subtitle: String? = nil
  var trailingText: String? = nil
  var trailingImage: Image? = nil
  //  var showChevron: Bool = true

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .foregroundColor(.primaryColor)
        if let subtitle = subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondaryColor)
        }
      }

      Spacer()

      if let trailingText = trailingText {
        Text(trailingText)
          .foregroundColor(.secondaryColor)
          .font(.subheadline)
      }

      if let trailingImage = trailingImage {
        trailingImage
          .foregroundColor(.secondaryColor)
      }

      //      if showChevron {
      //        Image(systemName: "chevron.right")
      //          .foregroundColor(.secondary)
      //          .font(.caption)
      //      }
    }
    .padding(.vertical, 14)
  }
}

private struct ToggleRow: View {
  let title: String
  var subtitle: String? = nil
  @Binding var isOn: Bool

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(title).foregroundColor(.primaryColor)
        if let subtitle = subtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondaryColor)
        }
      }

      Spacer()
      Toggle("", isOn: $isOn)
        .labelsHidden()
    }
    .padding(.vertical, 12)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
