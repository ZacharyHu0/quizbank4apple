//
//  HomeView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingNewChallenge = false
    @State private var showingQuestionBankSelector = false
    @State private var showingThemeSelector = false
    @State private var showingChallenge = false

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with theme selector
                        headerSection

                        // Welcome message
                        welcomeSection

                        // Main action buttons
                        actionButtonsSection

                        // Statistics overview
                        if !viewModel.isFirstTime {
                            statisticsSection
                        }

                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemBackground).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Quiz Challenge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingThemeSelector = true }) {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "challenge":
                    ChallengeView()
                        .environmentObject(viewModel)
                case "mistakes":
                    ReviewMistakesView()
                case "statistics":
                    StatsView()
                default:
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $showingNewChallenge) {
            NewChallengeView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingQuestionBankSelector) {
            QuestionBankSelectorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingThemeSelector) {
            ThemeSelectorView()
        }
        .onAppear {
            viewModel.loadAvailableQuestionBanks()
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("欢迎回来")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(getGreeting())
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }

            Spacer()

            LiquidGlassCard {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.accentColor)
                    Text(DateFormatter.shortDate.string(from: Date()))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
    }

    private var welcomeSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    Text("巴德年班模块考试 专用题库")
                        .font(.system(size: 20, weight: .semibold))
                }

                Text("通过互动测验提升你的知识水平，追踪学习进度，复习错题，让学习更高效。")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Continue Challenge button (only show if there's a current challenge)
            if viewModel.hasCurrentChallenge {
                LiquidGlassButton(
                    title: "继续挑战",
                    style: .primary
                ) {
                    viewModel.continueChallenge()
                    viewModel.navigationPath.append("challenge")
                }
            }

            // New Challenge button
            LiquidGlassButton(
                title: "新的挑战",
                style: .primary
            ) {
                showingNewChallenge = true
            }

            // Choose Question Bank button
            LiquidGlassButton(
                title: "选择题库",
                style: .secondary
            ) {
                showingQuestionBankSelector = true
            }

            // Review Mistakes button
            LiquidGlassButton(
                title: "查看错题",
                style: .danger
            ) {
                viewModel.showMistakesReview()
            }

            // Historical Statistics button
            LiquidGlassButton(
                title: "历史统计",
                style: .success
            ) {
                viewModel.showHistoricalStatistics()
            }
        }
    }

    private var statisticsSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("学习统计")
                    .font(.headline)
                    .fontWeight(.semibold)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatisticCard(
                        title: "总挑战",
                        value: "\(viewModel.userStats.totalChallenges)",
                        icon: "target",
                        color: .blue
                    )

                    StatisticCard(
                        title: "正确率",
                        value: String(format: "%.1f%%", viewModel.userStats.totalAccuracy),
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    StatisticCard(
                        title: "总题数",
                        value: "\(viewModel.userStats.totalQuestions)",
                        icon: "list.bullet",
                        color: .orange
                    )

                    StatisticCard(
                        title: "平均用时",
                        value: formatTime(viewModel.userStats.averageTimePerQuestion),
                        icon: "clock.fill",
                        color: .purple
                    )
                }
            }
        }
    }

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "早上好"
        case 12..<18:
            return "下午好"
        default:
            return "晚上好"
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        } else {
            return "\(seconds)秒"
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
}

#Preview {
    HomeView()
        .preferredColorScheme(.light)
}
