//
//  DataManager.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    public static let shared = DataManager()

    private let userDefaults = UserDefaults.standard
    private let currentChallengeKey = "currentChallenge"
    private let userStatsKey = "userStats"
    private let themeKey = "appTheme"

    var currentChallenge: Challenge? {
        didSet {
            saveCurrentChallenge()
        }
    }

    @Published var userStats: UserStats {
        didSet {
            saveUserStats()
        }
    }

    @Published var theme: AppTheme {
        didSet {
            saveTheme()
        }
    }

private init() {
        self.currentChallenge = Self.loadCurrentChallengeStatic()
        self.userStats = Self.loadUserStatsStatic()
        self.theme = Self.loadThemeStatic()
    }

    private static func loadCurrentChallengeStatic() -> Challenge? {
        guard let data = UserDefaults.standard.data(forKey: "currentChallenge") else { return nil }

        do {
            return try JSONDecoder().decode(Challenge.self, from: data)
        } catch {
            print("加载当前挑战失败: \(error)")
            return nil
        }
    }

    private static func loadUserStatsStatic() -> UserStats {
        guard let data = UserDefaults.standard.data(forKey: "userStats") else {
            return UserStats()
        }

        do {
            return try JSONDecoder().decode(UserStats.self, from: data)
        } catch {
            print("加载用户统计失败: \(error)")
            return UserStats()
        }
    }

    private static func loadThemeStatic() -> AppTheme {
        guard let data = UserDefaults.standard.data(forKey: "appTheme") else {
            return .system
        }

        do {
            return try JSONDecoder().decode(AppTheme.self, from: data)
        } catch {
            print("加载主题设置失败: \(error)")
            return .system
        }
    }

    // MARK: - 挑战管理
    func startNewChallenge(questionBank: String, questions: [Question]) {
        let challenge = Challenge(questionBank: questionBank, questions: questions)
        currentChallenge = challenge
    }

    func saveCurrentChallenge() {
        guard let challenge = currentChallenge else {
            userDefaults.removeObject(forKey: currentChallengeKey)
            return
        }

        do {
            let data = try JSONEncoder().encode(challenge)
            userDefaults.set(data, forKey: currentChallengeKey)
        } catch {
            print("保存当前挑战失败: \(error)")
        }
    }

    func loadCurrentChallenge() -> Challenge? {
        guard let data = userDefaults.data(forKey: currentChallengeKey) else { return nil }

        do {
            return try JSONDecoder().decode(Challenge.self, from: data)
        } catch {
            print("加载当前挑战失败: \(error)")
            return nil
        }
    }

    func completeCurrentChallenge() {
        guard var challenge = currentChallenge else { return }
        challenge.complete()
        userStats.recordChallenge(challenge)
        currentChallenge = nil
    }

    // MARK: - 用户统计管理
    func saveUserStats() {
        do {
            let data = try JSONEncoder().encode(userStats)
            userDefaults.set(data, forKey: userStatsKey)
        } catch {
            print("保存用户统计失败: \(error)")
        }
    }

    func loadUserStats() -> UserStats {
        guard let data = userDefaults.data(forKey: userStatsKey) else {
            return UserStats()
        }

        do {
            return try JSONDecoder().decode(UserStats.self, from: data)
        } catch {
            print("加载用户统计失败: \(error)")
            return UserStats()
        }
    }

    func resetAllData() {
        currentChallenge = nil
        userStats.resetAll()
    }

    // MARK: - 主题管理
    func saveTheme() {
        let themeData = try? JSONEncoder().encode(theme)
        userDefaults.set(themeData, forKey: themeKey)
    }

    func loadTheme() -> AppTheme {
        guard let data = userDefaults.data(forKey: themeKey) else {
            return .system
        }

        do {
            return try JSONDecoder().decode(AppTheme.self, from: data)
        } catch {
            print("加载主题设置失败: \(error)")
            return .system
        }
    }

    func setTheme(_ newTheme: AppTheme) {
        theme = newTheme
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var displayName: String {
        switch self {
        case .light:
            return "明亮"
        case .dark:
            return "深色"
        case .system:
            return "跟随系统"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
