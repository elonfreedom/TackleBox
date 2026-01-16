//
//  SearchView.swift
//  TackleBox
//
//  Created by GitHub Copilot on 2025/12/30.
//

import SwiftUI
import Combine
import SwiftData

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @Environment(\.modelContext) private var modelContext

    init(searchText: String = "") {
        _viewModel = StateObject(wrappedValue: SearchViewModel(searchText: searchText))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredItems.isEmpty {
                    if viewModel.query.isEmpty {
                        VStack(spacing: 8) {
                            Spacer()
                            Text("输入关键词以搜索装备")
                                .foregroundColor(.secondaryColor)
                            Text("支持按名称或分类搜索")
                                .font(.footnote)
                                .foregroundColor(.secondaryColor)
                            Spacer()
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("未找到匹配项")
                                .foregroundColor(.secondaryColor)
                            Spacer()
                        }
                    }
                } else {
                    List {
                        ForEach(viewModel.filteredItems, id: \.id) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    if let cat = item.category {
                                        Text(cat)
                                            .font(.caption)
                                            .foregroundColor(.secondaryColor)
                                    }
                                }
                                Spacer()
                                Button(action: { viewModel.toggleEquipped(item) }) {
                                    Image(systemName: item.isEquipped ? "checkmark.seal.fill" : "plus.circle")
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .navigationTitle("搜索")
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索装备或类别")
            .disableAutocorrection(true)
            .onAppear { viewModel.attach(modelContext: modelContext) }
            .appBackgrounded()
        }
        
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
