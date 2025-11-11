//
//  ReviewMistakesViewModel.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation
import Combine

class ReviewMistakesViewModel: ObservableObject {
    @Published var mistakes: [MistakeRecord] = []
    @Published var filteredMistakes: [MistakeRecord] = []
    @Published var selectedQuestionBanks: Set<String> = []
    @Published var availableQuestionBanks: Set<String> = []

    private let dataManager = DataManager.shared

    init() {
        loadMistakes()
    }

    func loadMistakes() {
        mistakes = dataManager.userStats.mistakesHistory.sorted { $0.timestamp > $1.timestamp }
        availableQuestionBanks = Set(mistakes.map { $0.questionBank })
        selectedQuestionBanks = availableQuestionBanks
        applySortAndFilter(mysort: .mostRecent, searchText: "")
    }

    func applySortAndFilter(mysort option: SortOption, searchText: String) {
        var filtered = Array(selectedQuestionBanks.isEmpty ? mistakes : mistakes.filter { selectedQuestionBanks.contains($0.questionBank) })

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { mistake in
                mistake.questionText.localizedCaseInsensitiveContains(searchText) ||
                mistake.questionBank.localizedCaseInsensitiveContains(searchText) ||
                mistake.options.joined().localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sorting
        switch option {
        case .mostRecent:
            filtered.sort { $0.timestamp > $1.timestamp }
        case .mostFrequent:
            filtered.sort { $0.errorCount > $1.errorCount }
        case .questionBank:
            filtered.sort { $0.questionBank < $1.questionBank }
        }

        filteredMistakes = filtered
    }

    func toggleQuestionBank(_ questionBank: String) {
        if selectedQuestionBanks.contains(questionBank) {
            selectedQuestionBanks.remove(questionBank)
        } else {
            selectedQuestionBanks.insert(questionBank)
        }
        applySortAndFilter(mysort: .mostRecent, searchText: "")
    }

    func clearMistakes(for questionBank: String? = nil) {
        dataManager.userStats.mistakesHistory.removeAll { mistake in
            questionBank == nil ? true : mistake.questionBank == questionBank
        }
        loadMistakes()
    }
}
