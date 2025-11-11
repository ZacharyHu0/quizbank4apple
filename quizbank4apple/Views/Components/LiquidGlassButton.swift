//
//  LiquidGlassButton.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import SwiftUI

struct LiquidGlassButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isEnabled: Bool

    enum ButtonStyle {
        case primary
        case secondary
        case danger
        case success

        var backgroundColor: Color {
            switch self {
            case .primary:
                return .blue.opacity(0.8)
            case .secondary:
                return .gray.opacity(0.6)
            case .danger:
                return .red.opacity(0.8)
            case .success:
                return .green.opacity(0.8)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .success:
                return .white
            case .secondary:
                return .primary
            case .danger:
                return .white
            }
        }
    }

    init(title: String, style: ButtonStyle = .primary, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.style = style
        self.isEnabled = isEnabled
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isEnabled ? style.foregroundColor : .gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isEnabled {
                        // Liquid glass background effect
                        RoundedRectangle(cornerRadius: 12)
                            .fill(style.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .overlay(
                                // Highlight effect
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        RadialGradient(
                                            colors: [.white.opacity(0.4), .clear],
                                            center: .topLeading,
                                            startRadius: 5,
                                            endRadius: 20
                                        )
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                    }
                }
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        LiquidGlassButton(title: "主要按钮", style: .primary) {
            print("Primary button tapped")
        }

        LiquidGlassButton(title: "次要按钮", style: .secondary) {
            print("Secondary button tapped")
        }

        LiquidGlassButton(title: "成功按钮", style: .success) {
            print("Success button tapped")
        }

        LiquidGlassButton(title: "危险按钮", style: .danger) {
            print("Danger button tapped")
        }

        LiquidGlassButton(title: "禁用按钮", style: .primary, isEnabled: false) {
            print("This should not be called")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
