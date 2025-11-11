//
//  LiquidGlassCard.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct LiquidGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.1),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 8)
            }
        )
    }
}

struct SimpleCard<Content: View>: View {
    let content: Content
    let padding: CGFloat

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        LiquidGlassCard {
            content
                .padding(padding)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SimpleCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("卡片标题")
                    .font(.headline)
                Text("这是一个具有Liquid Glass效果的卡片，展示了现代化的设计风格。")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }

        LiquidGlassCard {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading) {
                    Text("特殊卡片")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("带有图标和自定义内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
