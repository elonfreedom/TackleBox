//
//  ContentView.swift
//  TackleBox
//
//  Created by elonfreedom on 2025/12/6.
//

import SwiftUI
import SwiftData

struct ContentView: View {
        @SceneStorage("selectedTab") private var selectedTabIndex = 0 // 利用 @SceneStorage 持久化标签选择状态[1,6](@ref)
    @State private var searchText = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            Tab("装备", systemImage: "shippingbox", value: 0) {
                HomeView()
            }

            Tab("设置", systemImage: "gearshape", value: 1) {
                SettingsView()
            }

            Tab("搜索", systemImage: "magnifyingglass", value: 2, role: .search) {
                SearchView(searchText: searchText)
            }
        }
        .accentColor(Color(#colorLiteral(red: 0, green: 0.8, blue: 0.8, alpha: 1)))
        .tabViewStyle(.automatic)
        // .tabBarMinimizeBehavior(.never)
    }
}

#Preview {
    ContentView()
}
