//
//  ThemeSelectorView.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct ThemeSelectorView: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("主题设置")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, 10)

            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button(action: {
                    dataManager.setTheme(theme)
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        // Theme icon
                        Image(systemName: themeIcon)
                            .font(.system(size: 24))
                            .foregroundColor(themeColor)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(theme.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)

                            Text(themeDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        // Selection indicator
                        if dataManager.theme == theme {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeColor)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }

            Spacer()
        }
        .padding()
    }

    private var themeIcon: String {
        switch dataManager.theme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }

    private var themeColor: Color {
        switch dataManager.theme {
        case .light:
            return .orange
        case .dark:
            return .purple
        case .system:
            return .blue
        }
    }

    private var themeBackgroundColor: Color {
        switch dataManager.theme {
        case .light:
            return Color(.systemBackground)
        case .dark:
            return Color(.systemBackground).opacity(0.8)
        case .system:
            return Color(.systemBackground)
        }
    }

    private var themeDescription: String {
        switch dataManager.theme {
        case .light:
            return "使用明亮的界面主题"
        case .dark:
            return "使用深色的界面主题"
        case .system:
            return "跟随系统设置自动切换"
        }
    }
}

#Preview {
    ThemeSelectorView()
}
