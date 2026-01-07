//
//  TackleBoxApp.swift
//  TackleBox
//
//  Created by elonfreedom on 2025/12/6.
//

import SwiftUI
import SwiftData

@main
struct TackleBoxApp: App {
    @StateObject private var modelManager = ModelManager()

    init() {
        // 在应用首次启动时创建预置分类
        CategoryStore.shared.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
        }
        .modelContainer(modelManager.container)
    }
}
