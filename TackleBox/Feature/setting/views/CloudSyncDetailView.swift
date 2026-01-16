import SwiftUI

struct CloudSyncDetailView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(get: { viewModel.useICloudSync }, set: { viewModel.setICloudSync($0) })) {
                    VStack(alignment: .leading) {
                        Text("开启同步")
                    }
                }
            }

            Section(header: Text("状态")) {
                HStack {
                    Text("CloudKit 状态")
                    Spacer()
                    Text(viewModel.useICloudSync ? "已启用":"未启用")
                        .foregroundColor(.secondaryColor)
                }

//                Button("刷新状态") {
//                    viewModel.refreshCloudStatus()
//                }
            }
        }
              .appBackgrounded()
        .navigationTitle("iCloud 同步")
        .onAppear {
//            viewModel.refreshCloudStatus()
        }
    }
}

struct CloudSyncDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CloudSyncDetailView(viewModel: SettingsViewModel())
    }
}
