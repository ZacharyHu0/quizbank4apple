//
//  Challenge.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation

struct Challenge: Identifiable, Codable {
    let id: UUID
    let questionBank: String
    let startDate: Date
    var endDate: Date?
    var questions: [Question]
    var currentQuestionIndex: Int
    var isActive: Bool

    // 统计信息
    var answeredCount: Int {
        return questions.filter { $0.isAnswered }.count
    }

    var correctCount: Int {
        return questions.filter { $0.isCorrect }.count
    }

    var incorrectCount: Int {
        return answeredCount - correctCount
    }

    var totalCount: Int {
        return questions.count
    }

    var correctRate: Double {
        guard answeredCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(answeredCount) * 100
    }

    var isCompleted: Bool {
        return answeredCount == totalCount
    }

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(answeredCount) / Double(totalCount)
    }

    init(questionBank: String, questions: [Question]) {
        self.id = UUID()
        self.questionBank = questionBank
        self.startDate = Date()
        self.endDate = nil
        self.questions = questions.map { question in
            Question(
                questionId: question.questionId,
                year: question.year,
                module: question.module,
                week: question.week,
                questionText: question.questionText,
                options: question.options,
                correctAnswer: question.correctAnswer,
                questionBank: questionBank
            )
        }
        self.currentQuestionIndex = 0
        self.isActive = true
    }

    mutating func answerCurrentQuestion(_ answer: String) {
        guard currentQuestionIndex < questions.count else { return }
        questions[currentQuestionIndex].userAnswer = answer
    }

    mutating func markCurrentAsUnknown() {
        answerCurrentQuestion("不知道")
    }

    mutating func moveToNextQuestion() -> Bool {
        guard currentQuestionIndex < questions.count - 1 else {
            // 完成挑战
            isActive = false
            endDate = Date()
            return false
        }
        currentQuestionIndex += 1
        return true
    }

    mutating func moveToPreviousQuestion() -> Bool {
        guard currentQuestionIndex > 0 else { return false }
        currentQuestionIndex -= 1
        return true
    }

    mutating func complete() {
        isActive = false
        endDate = Date()
    }
}
