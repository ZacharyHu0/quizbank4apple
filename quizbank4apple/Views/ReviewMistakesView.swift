//
//  ReviewMistakesView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct ReviewMistakesView: View {
    @StateObject private var viewModel = ReviewMistakesViewModel()
    @State private var soption: SortOption = .mostRecent
    @State private var searchText = ""


    var body: some View {
        VStack(spacing: 0) {
                if viewModel.mistakes.isEmpty {
                    EmptyMistakesView()
                } else {
                    // Search and filter
                    searchAndFilterSection

                    // Mistakes list
                    mistakesList
                }
        }
        .navigationTitle("错题复习")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !viewModel.mistakes.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                soption = option
                                viewModel.applySortAndFilter(mysort: soption, searchText: searchText)
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if soption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMistakes()
        }
    }

    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("搜索错题...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        viewModel.applySortAndFilter(mysort: soption, searchText: searchText)
                    }

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.applySortAndFilter(mysort: soption, searchText: "")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.availableQuestionBanks).sorted(), id: \.self) { bank in
                        FilterChip(
                            title: bank,
                            isSelected: viewModel.selectedQuestionBanks.contains(bank),
                            onTap: {
                                viewModel.toggleQuestionBank(bank)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(Color.gray.opacity(0.05))
    }

    private var mistakesList: some View {
        List {
            ForEach(viewModel.filteredMistakes) { mistake in
                MistakeRow(mistake: mistake)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct EmptyMistakesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("太棒了！")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Text("目前还没有错题记录")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Text("继续挑战，巩固你的知识吧")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            LiquidGlassButton(
                title: "开始新挑战",
                style: .primary
            ) {
                // 这里可以添加导航到新挑战的逻辑
            }
        }
        .padding()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.8) : Color.gray.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MistakeRow: View {
    let mistake: MistakeRecord
    @State private var isExpanded = false

    var body: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mistake.questionBank)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)

                        Text("错误 \(mistake.errorCount) 次")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.red.opacity(0.1))
                            )
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                }

                // Question preview
                Text(mistake.questionText)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(isExpanded ? nil : 2)

                if isExpanded {
                    // Detailed answer information
                    VStack(spacing: 8) {
                        Divider()

                        // Options
                        VStack(alignment: .leading, spacing: 4) {
                            Text("选项")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            ForEach(mistake.options, id: \.self) { option in
                                HStack {
                                    Circle()
                                        .fill(optionColor(for: option))
                                        .frame(width: 8, height: 8)

                                    Text(option)
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    if option == mistake.correctAnswer {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 14))
                                    } else if option == mistake.userAnswer {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }

                        // Answer summary
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("你的答案:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(mistake.userAnswer)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }

                            HStack {
                                Text("正确答案:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(mistake.correctAnswer)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                        }

                        // Timestamp
                        Text(formatDate(mistake.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func optionColor(for option: String) -> Color {
        if option == mistake.correctAnswer {
            return .green
        } else if option == mistake.userAnswer {
            return .red
        } else {
            return .gray.opacity(0.5)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ReviewMistakesView()
}
