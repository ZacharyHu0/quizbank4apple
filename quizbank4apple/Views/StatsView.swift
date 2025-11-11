//
//  StatsView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var showingResetAlert = false
    @State private var selectedTimeRange: TimeRange = .allTime

    enum TimeRange: String, CaseIterable {
        case allTime = "全部时间"
        case thisWeek = "本周"
        case thisMonth = "本月"
    }

    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // Time range selector
                    timeRangeSelector

                    // Overview cards
                    overviewSection

                    // Performance chart
                    performanceChartSection

                    // Question bank performance
                    questionBankSection

                    // Recent activity
                    recentActivitySection

                    // Reset button
                    resetSection

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .navigationTitle("历史统计")
        .navigationBarTitleDisplayMode(.large)
        .alert("重置数据", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确认重置", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("这将删除所有统计数据和错题记录，此操作无法撤销。")
        }
        .onAppear {
            viewModel.loadStats()
        }
    }

    private var timeRangeSelector: some View {
        HStack {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    selectedTimeRange = range
                    viewModel.updateTimeRange(range)
                }) {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTimeRange == range ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(selectedTimeRange == range ? 1.0 : 0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    private var overviewSection: some View {
        SimpleCard {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("学习概览")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatisticCard(
                        title: "总挑战数",
                        value: "\(viewModel.totalChallenges)",
                        icon: "target",
                        color: .blue
                    )

                    StatisticCard(
                        title: "总题数",
                        value: "\(viewModel.totalQuestions)",
                        icon: "list.bullet",
                        color: .orange,

                    )

                    StatisticCard(
                        title: "正确率",
                        value: String(format: "%.1f%%", viewModel.accuracy),
                        icon: "checkmark.circle.fill",
                        color: .green,

                    )

                    StatisticCard(
                        title: "平均用时",
                        value: formatTime(viewModel.averageTime),
                        icon: "clock.fill",
                        color: .purple,

                    )
                }
            }
        }
    }

    private var performanceChartSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    Text("表现趋势")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                if viewModel.challengeHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("暂无数据")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                } else {
                    Chart {
                        ForEach(viewModel.challengeHistory, id: \.id) { challenge in
                            LineMark(
                                x: .value("时间", challenge.startDate, unit: .day),
                                y: .value("正确率", challenge.accuracy)
                            )
                            .foregroundStyle(.blue)
                            .symbol(.circle)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(formatChartDate(date))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let percentage = value.as(Double.self) {
                                    Text(String(format: "%.0f%%", percentage))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var questionBankSection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                    Text("题库表现")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 12) {
                    ForEach(viewModel.questionBankStats, id: \.name) { stat in
                        QuestionBankStatRow(stat: stat)
                    }
                }
            }
        }
    }

    private var recentActivitySection: some View {
        SimpleCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                    Text("最近活动")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                if viewModel.recentChallenges.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)

                        Text("最近没有挑战记录")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.recentChallenges.prefix(5), id: \.id) { challenge in
                            RecentChallengeRow(challenge: challenge)
                        }
                    }
                }
            }
        }
    }

    private var resetSection: some View {
        VStack(spacing: 16) {
            LiquidGlassButton(
                title: "重置所有数据",
                style: .danger
            ) {
                showingResetAlert = true
            }

            Text("重置将删除所有统计数据和错题记录")
                .font(.caption)
                .foregroundColor(.secondary)
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

    private func formatChartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct QuestionBankStatRow: View {
    let stat: StatsViewModel.QuestionBankStat

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(stat.name)
                    .font(.system(size: 15, weight: .medium))

                Spacer()

                Text(String(format: "%.1f%%", stat.accuracy))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(stat.accuracy >= 70 ? .green : .orange)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: stat.accuracy >= 70 ? [.green, .green.opacity(0.8)] : [.orange, .orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (stat.accuracy / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(stat.totalChallenges) 次挑战")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(stat.totalQuestions) 道题目")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RecentChallengeRow: View {
    let challenge: ChallengeStats

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.questionBank)
                    .font(.system(size: 14, weight: .medium))

                Text(formatDate(challenge.startDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", challenge.accuracy))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(challenge.accuracy >= 70 ? .green : .orange)

                Text("\(challenge.correctAnswers)/\(challenge.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    StatsView()
}
