//
//  quizbank4appleApp.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

@main
struct quizbank4appleApp: App {
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .preferredColorScheme(dataManager.theme.colorScheme)
        }
    }
}
