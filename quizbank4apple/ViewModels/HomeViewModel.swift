//
//  HomeViewModel.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var availableQuestionBanks: [String] = []
    @Published var hasCurrentChallenge: Bool = false
    @Published var userStats: UserStats
    @Published var navigationPath = NavigationPath()

    private let dataManager = DataManager.shared

    var isFirstTime: Bool {
        return userStats.totalChallenges == 0
    }

    init() {
        self.userStats = dataManager.userStats
        self.hasCurrentChallenge = dataManager.currentChallenge != nil
    }

    func loadAvailableQuestionBanks() {
        availableQuestionBanks = CSVParser.getAvailableQuestionBanks()
    }

    func startNewChallenge(with questionBank: String) {
        do {
            let questions = try CSVParser.parseCSV(from: questionBank)
            guard !questions.isEmpty else {
                print("题库为空: \(questionBank)")
                return
            }

            // 随机打乱题目顺序
            let shuffledQuestions = questions.shuffled()
            dataManager.startNewChallenge(questionBank: questionBank, questions: shuffledQuestions)
            hasCurrentChallenge = true

            // 导航到挑战页面
            navigationPath.append("challenge")
        } catch {
            print("加载题库失败: \(error)")
        }
    }

    func continueChallenge() {
        guard dataManager.currentChallenge != nil else { return }
        hasCurrentChallenge = true
        navigationPath.append("challenge")
    }

    func showMistakesReview() {
        if userStats.mistakesHistory.isEmpty {
            print("暂无错题记录")
            return
        }
        navigationPath.append("mistakes")
    }

    func showHistoricalStatistics() {
        navigationPath.append("statistics")
    }

    func completeCurrentChallenge() {
        dataManager.completeCurrentChallenge()
        hasCurrentChallenge = false
        userStats = dataManager.userStats

        // 重置导航路径回到主页
        navigationPath = NavigationPath()
    }

    func resetAllData() {
        dataManager.resetAllData()
        userStats = dataManager.userStats
        hasCurrentChallenge = false
        navigationPath = NavigationPath()
    }
}
