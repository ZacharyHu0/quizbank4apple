//
//  QuestionBankSelectorView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct QuestionBankSelectorView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
                if viewModel.availableQuestionBanks.isEmpty {
                    EmptyStateView()
                } else {
                    QuestionBankList(
                        questionBanks: viewModel.availableQuestionBanks,
                        onSelectQuestionBank: { questionBank in
                            viewModel.startNewChallenge(with: questionBank)
                            dismiss()
                        }
                    )
                }
        }
        .navigationTitle("选择题库")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.loadAvailableQuestionBanks()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("暂无可用题库")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("请确保Data文件夹中有CSV题库文件")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct QuestionBankList: View {
    let questionBanks: [String]
    let onSelectQuestionBank: (String) -> Void

    var body: some View {
        List(questionBanks, id: \.self) { questionBank in
            Button(action: { onSelectQuestionBank(questionBank) }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(questionBank)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)

                        Text("CSV题库文件")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    QuestionBankSelectorView(viewModel: HomeViewModel())
}
