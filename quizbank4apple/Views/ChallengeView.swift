//
//  ChallengeView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct ChallengeView: View {
    @StateObject private var viewModel = ChallengeViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var showingCompletionAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            progressHeader

            // Question content
            if let question = viewModel.currentQuestion {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {
                            QuestionCard(question: question) { selectedAnswer in
                                viewModel.answerCurrentQuestion(selectedAnswer)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 80) // 为底部固定按钮留出充足空间
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .clipped() // 确保内容不超出边界
            } else {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("没有可用的题目")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            // Navigation buttons - 使用安全区域固定在底部
            if viewModel.currentQuestion != nil {
                VStack(spacing: 0) {
                    Divider()
                    navigationButtons
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)

                    // Progress dots - 底部显示
                    BottomProgressIndicator(
                        currentIndex: viewModel.currentQuestionIndex,
                        totalQuestions: viewModel.totalQuestions,
                        answeredQuestions: viewModel.questions.map { $0.isAnswered },
                        correctQuestions: viewModel.questions.map { $0.isCorrect },
                        onDotTapped: viewModel.jumpToQuestion
                    )
                }
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // 忽略键盘区域
        .navigationTitle(viewModel.questionBank)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("退出") {
                    showingCompletionAlert = true
                }
                .foregroundColor(.red)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .alert("确认退出", isPresented: $showingCompletionAlert) {
            Button("取消", role: .cancel) { }
            Button("保存并退出", role: .none) {
                viewModel.saveAndExit()
                homeViewModel.navigationPath.removeLast()
            }
            Button("放弃挑战", role: .destructive) {
                homeViewModel.navigationPath.removeLast()
            }
        } message: {
            Text("您的进度将会保存，下次可以继续挑战。")
        }
        .alert("挑战完成", isPresented: $viewModel.showingCompletionAlert) {
            Button("查看统计") {
                homeViewModel.navigationPath.append("statistics")
            }
            Button("返回主页", role: .none) {
                homeViewModel.navigationPath = NavigationPath()
            }
        } message: {
            Text(completionMessage)
        }
        .onAppear {
            viewModel.loadChallenge()
        }
    }

    private var progressHeader: some View {
        // Statistics bar
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("进度")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.answeredCount)/\(viewModel.totalQuestions)")
                    .font(.system(size: 16, weight: .semibold))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("正确率")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f%%", viewModel.correctRate))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.correctRate >= 60 ? .green : .orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(.ultraThinMaterial)
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Previous button
            LiquidGlassButton(
                title: "上一题",
                style: viewModel.canGoToPrevious ? .primary : .secondary,
                isEnabled: viewModel.canGoToPrevious
            ) {
                viewModel.goToPreviousQuestion()
            }

            // Unknown button
            LiquidGlassButton(
                title: "不知道",
                style: .danger
            ) {
                viewModel.markAsUnknown()
            }

            // Next button
            LiquidGlassButton(
                title: viewModel.isLastQuestion ? "完成" : "下一题",
                style: viewModel.canGoToNext ? .primary : .secondary,
                isEnabled: true // 总是可用的
            ) {
                if viewModel.isLastQuestion {
                    viewModel.completeChallenge()
                } else {
                    viewModel.goToNextQuestion()
                }
            }
        }
    }

    private var completionMessage: String {
        return """
        恭喜完成挑战！

        总题数：\(viewModel.totalQuestions)
        正确：\(viewModel.correctCount) 题
        正确率：\(String(format: "%.1f%%", viewModel.correctRate))
        用时：\(formatTime(viewModel.duration))
        """
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return "\(minutes)分\(seconds)秒"
    }
}


struct QuestionCard: View {
    let question: Question
    let onAnswerSelected: (String) -> Void

    var body: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 24) {
                // Question text section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        Text("题目")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Text(question.questionText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Answer options section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        Text("选项")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(2, question.options.count)), spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            AnswerOptionButton(
                                option: option,
                                isSelected: question.userAnswer == option,
                                isCorrect: question.userAnswer != nil ? (option == question.correctAnswer) : nil,
                                onTap: {
                                    if question.userAnswer == nil {
                                        onAnswerSelected(option)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 8) // 减少内部padding
        }
        .frame(maxWidth: .infinity) // 确保卡片占据最大宽度
    }
}

struct AnswerOptionButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Text(option)
                    .font(.system(size: 15))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                if isCorrect != nil {
                    Image(systemName: isCorrect! ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isCorrect! ? .green : .red)
                        .alignmentGuide(.top) { _ in 0 } // 与文本顶部对齐
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
        .disabled(isCorrect != nil)
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(isCorrect == nil) // 只在未回答时允许点击
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var backgroundColor: Color {
        if isCorrect != nil {
            return isCorrect! ? .green.opacity(0.1) : (isSelected ? .red.opacity(0.1) : .clear)
        } else if isSelected {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }

    private var borderColor: Color {
        if isCorrect != nil {
            return isCorrect! ? .green : (isSelected ? .red : .gray.opacity(0.3))
        } else if isSelected {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }

    private var textColor: Color {
        if isCorrect != nil {
            return isCorrect! ? .green : .primary
        } else {
            return .primary
        }
    }
}

struct BottomProgressIndicator: View {
    let currentIndex: Int
    let totalQuestions: Int
    let answeredQuestions: [Bool]
    let correctQuestions: [Bool]
    let onDotTapped: (Int) -> Void

    // 根据屏幕宽度计算每行的点数
    private var dotsPerRow: Int {
        return Int(UIScreen.main.bounds.width / 50) // 每个点大约50pt宽度（包括间距）
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: max(1, dotsPerRow)), spacing: 12) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        LiquidGlassProgressDot(
                            isAnswered: answeredQuestions[index],
                            isCorrect: correctQuestions[index],
                            isCurrent: index == currentIndex,
                            index: index,
                            onDotTapped: {
                                // 点击进度点跳转到对应题目
                                onDotTapped(index)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden) // 隐藏滚动条
        }
        .frame(height: 80) // 固定高度，支持多行
        .background(.ultraThinMaterial)
    }
}

struct LiquidGlassProgressDot: View {
    let isAnswered: Bool
    let isCorrect: Bool
    let isCurrent: Bool
    let index: Int
    let onDotTapped: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // Liquid Glass 样式的进度点 - 整个区域可点击
            Button(action: onDotTapped) {
                VStack(spacing: 4) {
                    // Liquid Glass 样式的进度点
                    Circle()
                        .fill(dotColor)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
                                .scaleEffect(isCurrent ? 1.2 : 1.0)
                        )
                        .background(
                            Circle()
                                .fill(
                                    RadialGradient(
                                            colors: [.white.opacity(0.2), .clear],
                                            center: .topLeading,
                                            startRadius: 2,
                                            endRadius: 6
                                        )
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: isCurrent)

                    // 题号 - 根据状态显示不同样式
                    Text("\(index + 1)")
                        .font(.system(size: 8, weight: .medium))
                        .fontWeight(isCurrent ? .bold : .regular)
                        .foregroundColor(isCurrent ? .blue : (isAnswered ? .primary : .secondary))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(4)
        }
    }

    private var dotColor: Color {
        if !isAnswered {
            return Color.gray.opacity(0.4)
        } else if isCorrect {
            return Color.green
        } else {
            return Color.red
        }
    }
}

#Preview {
    ChallengeView()
        .environmentObject(HomeViewModel())
        .environmentObject(DataManager.shared)
}
