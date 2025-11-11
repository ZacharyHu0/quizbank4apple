//
//  NewChallengeView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct NewChallengeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)

                    Text("开始新挑战")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("选择题库开始新的学习挑战")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Question bank list
                if viewModel.availableQuestionBanks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)

                        Text("暂无可用题库")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("请确保Data文件夹中有CSV题库文件")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.availableQuestionBanks, id: \.self) { questionBank in
                                QuestionBankRow(
                                    questionBank: questionBank,
                                    onStartChallenge: {
                                        viewModel.startNewChallenge(with: questionBank)
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
        }
        .navigationTitle("新挑战")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
        }
    }
}

struct QuestionBankRow: View {
    let questionBank: String
    let onStartChallenge: () -> Void

    var body: some View {
        SimpleCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(questionBank)
                        .font(.system(size: 16, weight: .semibold))

                    Text("点击开始挑战")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onStartChallenge) {
                    HStack(spacing: 6) {
                        Text("开始")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    NewChallengeView(viewModel: HomeViewModel())
}
