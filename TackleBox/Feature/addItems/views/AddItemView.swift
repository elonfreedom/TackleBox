import SwiftUI
import SwiftData

private extension View {
    func inputStyle() -> some View {
        self
            .padding(12)
            .background(Color.surfaceColor)
            .cornerRadius(12)
            .foregroundColor(.white)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding(.top, 6)
    }
}

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
                .background(Color.surfaceColor)
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
    var editingItem: Equipment? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddItemViewModel()
    @State private var didPopulateFromEditing = false

    var body: some View {
        Form {
            Section(header: Text("名称").sectionHeaderStyle()) {
                TextField("例如：路亚竿", text: $viewModel.name)
                    .inputStyle()
            }

            Section(header: Text("分类").sectionHeaderStyle()) {
                Picker("分类", selection: $viewModel.category) {
                    ForEach(viewModel.categories, id: \.name) { cat in
                        Text(cat.name)
                    }
                }
                .pickerStyle(.menu)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(Color.surfaceColor)
                .cornerRadius(12)
            }

            // Dynamic attributes for selected category
            if let attrs = viewModel.selectedCategory?.attributes, !attrs.isEmpty {
                Section(header: Text("属性")) {
                    ForEach(attrs) { attr in
                        switch attr.type {
                        case .text:
                            TextField(attr.label, text: binding(for: attr.key))
                                .inputStyle()
                        case .number:
                            TextField(attr.label, text: binding(for: attr.key))
                                .keyboardType(.decimalPad)
                                .inputStyle()
                        case .picker:
                            if let options = attr.options {
                                Picker(attr.label, selection: binding(for: attr.key)) {
                                    ForEach(options, id: \.self) { o in Text(o) }
                                }
                                .pickerStyle(.menu)
                            } else {
                                TextField(attr.label, text: binding(for: attr.key))
                                    .inputStyle()
                            }
                        }
                    }
                }
            }

            Section(header: Text("数量").sectionHeaderStyle()) {
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

            Section(header: Text("状态").sectionHeaderStyle()) {
                Picker("状态", selection: $viewModel.status) {
                    ForEach(viewModel.statuses, id: \.self) { s in
                        Text(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical,4)
            }

            Section(header: Text("备注").sectionHeaderStyle()) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 50)
                    .inputStyle()
            }

            Section {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                    Text("数据将离线保存，并在联网时自动同步到 CloudKit。")
                        .font(.footnote)
                        .foregroundColor(.secondaryColor)
                }
                .padding(8)
                .background(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle("添加装备")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: save) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .appBackgrounded()
        .onAppear {
            guard !didPopulateFromEditing, let e = editingItem else { return }
            // populate viewModel from existing Equipment for edit
            viewModel.name = e.name
            viewModel.category = e.category ?? viewModel.category
            viewModel.quantity = e.quantity
            viewModel.status = e.status
            viewModel.notes = e.notes ?? ""

            if let json = e.attributesJSON, let data = json.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let dict = try decoder.decode([String: String].self, from: data)
                    // overwrite attributeValues (preserve keys initialized by category)
                    for (k, v) in dict { viewModel.attributeValues[k] = v }
                } catch {
                    // ignore parse errors
                }
            }

            didPopulateFromEditing = true
        }
    }

    private func save() {
        if viewModel.save(context: modelContext, existing: editingItem) {
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
