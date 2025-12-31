import SwiftUI
import SwiftData

private struct RepeatButton: View {
    let systemName: String
    let action: () -> Void
    var longPressInterval: TimeInterval = 0.1

    @State private var timer: Timer? = nil
    @State private var pressing = false
    @State private var isLongPressing = false
    @State private var suppressNextTap = false

    var body: some View {
        Button(action: {
            if suppressNextTap {
                suppressNextTap = false
                return
            }
            action()
        }) {
            Image(systemName: systemName)
                .frame(width: 36, height: 36)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.28, pressing: { pressing in
            if pressing {
                self.pressing = true
                let delay = 0.28
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if self.pressing {
                        self.isLongPressing = true
                        self.suppressNextTap = true
                        action()
                        startTimer()
                    }
                }
            } else {
                self.pressing = false
                if self.isLongPressing {
                    stopTimer()
                    self.isLongPressing = false
                }
            }
        }, perform: {})
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: longPressInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddItemViewModel()

    var body: some View {
        Form {
            Section(header: Text("名称")) {
                TextField("例如：路亚竿", text: $viewModel.name)
                    .textFieldStyle(.plain)
            }

            Section(header: Text("分类")) {
                Picker("分类", selection: $viewModel.category) {
                    ForEach(viewModel.categories, id: \.name) { cat in
                        Text(cat.name)
                    }
                }
                .pickerStyle(.menu)
            }

            // Dynamic attributes for selected category
            if let attrs = viewModel.selectedCategory?.attributes, !attrs.isEmpty {
                Section(header: Text("属性")) {
                    ForEach(attrs) { attr in
                        switch attr.type {
                        case .text:
                            TextField(attr.label, text: binding(for: attr.key))
                                .textFieldStyle(.roundedBorder)
                        case .number:
                            TextField(attr.label, text: binding(for: attr.key))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        case .picker:
                            if let options = attr.options {
                                Picker(attr.label, selection: binding(for: attr.key)) {
                                    ForEach(options, id: \.self) { o in Text(o) }
                                }
                                .pickerStyle(.menu)
                            } else {
                                TextField(attr.label, text: binding(for: attr.key))
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }
            }

            Section(header: Text("数量")) {
                HStack {
                    RepeatButton(systemName: "minus") {
                        if viewModel.quantity > 1 { viewModel.quantity -= 1 }
                    }

                    Spacer()
                    Text("\(viewModel.quantity)")
                        .font(.headline)
                    Spacer()

                    RepeatButton(systemName: "plus") {
                        viewModel.quantity += 1
                    }
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("状态")) {
                Picker("状态", selection: $viewModel.status) {
                    ForEach(viewModel.statuses, id: \.self) { s in
                        Text(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical,4)
            }

            Section(header: Text("备注")) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 50)
            }

            Section {
                HStack {
                    Image(systemName: "info.circle")
                    Text("数据将离线保存，并在联网时自动同步到 CloudKit。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("添加装备")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: save) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }

    private func save() {
//        let context = modelContext
        if viewModel.save(context: modelContext) {
            dismiss()
        } else {
            // Could show an alert for validation failure
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(get: {
            viewModel.attributeValues[key] ?? ""
        }, set: { new in
            viewModel.attributeValues[key] = new
        })
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddItemView()
        }
    }
}
