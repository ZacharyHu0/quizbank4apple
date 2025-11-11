//
//  ChallengeViewModel.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation
import SwiftUI
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var questionBank: String = ""
    @Published var showingCompletionAlert: Bool = false
    @Published var navigationPath = NavigationPath()

    let dataManager = DataManager.shared

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        return questions.count
    }

    var answeredCount: Int {
        return questions.filter { $0.isAnswered }.count
    }

    var correctCount: Int {
        return questions.filter { $0.isCorrect }.count
    }

    var correctRate: Double {
        guard answeredCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(answeredCount) * 100
    }

    var canGoToPrevious: Bool {
        return currentQuestionIndex > 0
    }

    var canGoToNext: Bool {
        return currentQuestionIndex < questions.count - 1
    }

    var isLastQuestion: Bool {
        return currentQuestionIndex == questions.count - 1
    }

    var duration: TimeInterval {
        guard let challenge = dataManager.currentChallenge else { return 0 }
        return Date().timeIntervalSince(challenge.startDate)
    }

    init() {
        loadChallenge()
    }

    func loadChallenge() {
        guard let challenge = dataManager.currentChallenge else { return }

        questions = challenge.questions
        currentQuestionIndex = challenge.currentQuestionIndex
        questionBank = challenge.questionBank
    }

    func answerCurrentQuestion(_ answer: String) {
        guard currentQuestionIndex < questions.count else { return }
        questions[currentQuestionIndex].userAnswer = answer

        // 更新dataManager中的挑战数据
        updateChallengeInDataManager()
    }

    func markAsUnknown() {
        answerCurrentQuestion("不知道")
    }

    func goToPreviousQuestion() {
        guard canGoToPrevious else { return }
        currentQuestionIndex -= 1
        updateChallengeInDataManager()
    }

    func goToNextQuestion() {
        guard canGoToNext else { return }
        currentQuestionIndex += 1
        updateChallengeInDataManager()
    }

    func jumpToQuestion(at index: Int) {
        guard index >= 0 && index < questions.count else { return }
        currentQuestionIndex = index
        updateChallengeInDataManager()
    }

    func completeChallenge() {
        // 确保所有题目都被回答
        for index in 0..<questions.count {
            if questions[index].userAnswer == nil {
                currentQuestionIndex = index
                return // 提示用户需要回答所有题目
            }
        }

        // 完成挑战
        dataManager.completeCurrentChallenge()
        showingCompletionAlert = true
    }

    func saveAndExit() {
        updateChallengeInDataManager()
    }

    func navigateToStatistics() {
        navigationPath.append("statistics")
    }

    private func updateChallengeInDataManager() {
        guard var challenge = dataManager.currentChallenge else { return }

        // 更新挑战中的问题
        for (index, question) in questions.enumerated() {
            if index < challenge.questions.count {
                challenge.questions[index] = question
            }
        }

        // 更新当前题目索引
        challenge.currentQuestionIndex = currentQuestionIndex

        // 保存到dataManager
        dataManager.currentChallenge = challenge
    }
}
