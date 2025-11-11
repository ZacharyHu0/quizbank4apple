//
//  UserStats.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation

struct UserStats: Codable {
    var totalChallenges: Int
    var totalQuestions: Int
    var totalCorrectAnswers: Int
    var totalIncorrectAnswers: Int
    var averageTimePerQuestion: TimeInterval
    var challengesHistory: [ChallengeStats]
    var mistakesHistory: [MistakeRecord]

    var totalAccuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(totalCorrectAnswers) / Double(totalQuestions) * 100
    }

    var totalSpentTime: TimeInterval {
        return challengesHistory.reduce(0) { $0 + $1.duration }
    }

    init() {
        self.totalChallenges = 0
        self.totalQuestions = 0
        self.totalCorrectAnswers = 0
        self.totalIncorrectAnswers = 0
        self.averageTimePerQuestion = 0.0
        self.challengesHistory = []
        self.mistakesHistory = []
    }

    mutating func recordChallenge(_ challenge: Challenge) {
        let challengeStats = ChallengeStats(from: challenge)
        challengesHistory.append(challengeStats)

        totalChallenges += 1
        totalQuestions += challenge.totalCount
        totalCorrectAnswers += challenge.correctCount
        totalIncorrectAnswers += challenge.incorrectCount

        updateAverageTime()
        updateMistakesHistory(from: challenge)
    }

    private mutating func updateAverageTime() {
        guard totalQuestions > 0 else { return }
        averageTimePerQuestion = totalSpentTime / Double(totalQuestions)
    }

    private mutating func updateMistakesHistory(from challenge: Challenge) {
        for question in challenge.questions where question.isAnswered && !question.isCorrect {
            let record = MistakeRecord(
                questionId: question.id,
                questionText: question.questionText,
                userAnswer: question.userAnswer ?? "",
                correctAnswer: question.correctAnswer,
                options: question.options,
                questionBank: challenge.questionBank,
                timestamp: Date(),
                errorCount: 1
            )

            // 检查是否已有相同错误记录
            if let index = mistakesHistory.firstIndex(where: { $0.questionId == record.questionId }) {
                mistakesHistory[index].timestamp = record.timestamp
                mistakesHistory[index].errorCount += 1
            } else {
                mistakesHistory.append(record)
            }
        }
    }

    mutating func resetAll() {
        totalChallenges = 0
        totalQuestions = 0
        totalCorrectAnswers = 0
        totalIncorrectAnswers = 0
        averageTimePerQuestion = 0.0
        challengesHistory.removeAll()
        mistakesHistory.removeAll()
    }
}

struct ChallengeStats: Codable {
    let id: UUID
    let questionBank: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalQuestions: Int
    let correctAnswers: Int
    let accuracy: Double

    init(from challenge: Challenge) {
        self.id = challenge.id
        self.questionBank = challenge.questionBank
        self.startDate = challenge.startDate
        self.endDate = challenge.endDate ?? Date()
        self.duration = endDate.timeIntervalSince(startDate)
        self.totalQuestions = challenge.totalCount
        self.correctAnswers = challenge.correctCount
        self.accuracy = challenge.correctRate
    }
}

struct MistakeRecord: Identifiable, Codable {
    let id = UUID()
    let questionId: String
    let questionText: String
    let userAnswer: String
    let correctAnswer: String
    let options: [String]
    let questionBank: String
    var timestamp: Date
    var errorCount: Int
}

enum SortOption: String, CaseIterable {
    case mostRecent = "最新错误"
    case mostFrequent = "错误最多"
    case questionBank = "题库分组"
}
