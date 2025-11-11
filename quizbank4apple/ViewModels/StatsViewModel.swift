//
//  StatsViewModel.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation
import Combine

class StatsViewModel: ObservableObject {
    @Published var totalChallenges: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var accuracy: Double = 0.0
    @Published var averageTime: TimeInterval = 0.0
    @Published var challengeHistory: [ChallengeStats] = []
    @Published var questionBankStats: [QuestionBankStat] = []
    @Published var recentChallenges: [ChallengeStats] = []

    private let dataManager = DataManager.shared
    private var currentTimeRange: StatsView.TimeRange = .allTime

    struct QuestionBankStat: Identifiable {
        let id = UUID()
        let name: String
        let totalChallenges: Int
        let totalQuestions: Int
        let accuracy: Double
    }

    init() {
        loadStats()
    }

    func loadStats() {
        let userStats = dataManager.userStats

        totalChallenges = userStats.totalChallenges
        totalQuestions = userStats.totalQuestions
        accuracy = userStats.totalAccuracy
        averageTime = userStats.averageTimePerQuestion
        challengeHistory = userStats.challengesHistory
        recentChallenges = Array(challengeHistory.sorted { $0.startDate > $1.startDate })
        calculateQuestionBankStats()
    }

    func updateTimeRange(_ timeRange: StatsView.TimeRange) {
        currentTimeRange = timeRange
        loadStats()

        // Filter data based on time range
        let calendar = Calendar.current
        let now = Date()

        switch timeRange {
        case .thisWeek:
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                challengeHistory = challengeHistory.filter { $0.startDate >= weekAgo }
                recentChallenges = recentChallenges.filter { $0.startDate >= weekAgo }
            }
        case .thisMonth:
            if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) {
                challengeHistory = challengeHistory.filter { $0.startDate >= monthAgo }
                recentChallenges = recentChallenges.filter { $0.startDate >= monthAgo }
            }
        case .allTime:
            break
        }

        // Recalculate stats based on filtered data
        recalculateStatsFromHistory()
        calculateQuestionBankStats()
    }

    func resetAllData() {
        dataManager.resetAllData()
        loadStats()
    }

    private func recalculateStatsFromHistory() {
        totalChallenges = challengeHistory.count
        totalQuestions = challengeHistory.reduce(0) { $0 + $1.totalQuestions }

        let totalCorrect = challengeHistory.reduce(0) { $0 + $1.correctAnswers }
        accuracy = totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0.0

        let totalTime = challengeHistory.reduce(0.0) { $0 + $1.duration }
        averageTime = totalQuestions > 0 ? totalTime / Double(totalQuestions) : 0.0
    }

    private func calculateQuestionBankStats() {
        let groupedByBank = Dictionary(grouping: challengeHistory) { $0.questionBank }

        questionBankStats = groupedByBank.map { (bank, challenges) in
            let totalQuestions = challenges.reduce(0) { $0 + $1.totalQuestions }
            let totalCorrect = challenges.reduce(0) { $0 + $1.correctAnswers }
            let accuracy = totalQuestions > 0 ? (Double(totalCorrect) / Double(totalQuestions)) * 100 : 0.0

            return QuestionBankStat(
                name: bank,
                totalChallenges: challenges.count,
                totalQuestions: totalQuestions,
                accuracy: accuracy
            )
        }.sorted { $0.name < $1.name }
    }
}
