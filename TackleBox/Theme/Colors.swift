//
// Colors.swift
// 应用配色定义（语义化调色板）

import SwiftUI

enum AppColor {
    // 直接映射到 Assets.xcassets 中的颜色（使用带 "Color" 后缀的资产名）
    static let primaryColor = Color("PrimaryColor")
    static let secondaryColor = Color("SecondaryColor")
    static let backgroundColor = Color("BackgroundColor")
    static let surfaceColor = Color("SurfaceColor")
    static let accentColor = Color("AccentColor")

    // 语义化扩展：若需要可以基于资产或程序计算值
    static let primaryVariantColor: Color = {
        // 示例：基于主色的半透明变体
        AppColor.primaryColor.opacity(0.92)
    }()

    static let onPrimaryColor: Color = {
        // 在主色背景上的文本颜色（自动选择白/黑也可用 Color.primaryColor.contrast）
        Color.white
    }()

    static let onSecondaryColor: Color = Color.white

    // Surface / 背景辅助色
    static let backgroundElevatedColor: Color = AppColor.surfaceColor
    static let borderColor: Color = Color(.separator)

    // 常用意图色（错误/警告/成功）
    static let errorColor: Color = Color(red: 0.78, green: 0.16, blue: 0.18)
    static let warningColor: Color = Color(red: 0.95, green: 0.63, blue: 0.12)
    static let successColor: Color = Color(red: 0.09, green: 0.56, blue: 0.46)

    // 文本颜色
    static let textPrimaryColor: Color = Color.primaryColor == Color("PrimaryColor") ? Color.primary : Color.black
    static let textSecondaryColor: Color = Color(.secondaryLabel)

    // 禁用 / 占位 颜色
    static let disabledColor: Color = Color(.tertiaryLabel)
}

extension Color {
    // 主色：用于主要操作、强调按钮、重要交互元素
    static var primaryColor: Color { AppColor.primaryColor }

    // 次要色：用于次级操作或辅助强调（替代主色的较弱强调）
    static var secondaryColor: Color { AppColor.secondaryColor }

    // 页面背景色：用于视图主背景
    static var backgroundColor: Color { AppColor.backgroundColor }

    // 表面色：用于卡片、面板、浮层等表面背景
    static var surfaceColor: Color { AppColor.surfaceColor }

    // 强调色：用于图标、链接、小面积强调
    static var accentColor: Color { AppColor.accentColor }

    // 主色变体：主色的可复用变体（如按下/悬停/分层背景）
    static var primaryVariantColor: Color { AppColor.primaryVariantColor }

    // 主色上的前景（文本/图标），用于放在主色背景上的内容
    static var onPrimaryColor: Color { AppColor.onPrimaryColor }

    // 次要色上的前景，放在次要色背景上的文本/图标
    static var onSecondaryColor: Color { AppColor.onSecondaryColor }

    // 提升背景（如卡片或浮层的背景）
    static var backgroundElevatedColor: Color { AppColor.backgroundElevatedColor }

    // 边框/分隔线颜色
    static var borderColor: Color { AppColor.borderColor }

    // 状态色：错误/警告/成功
    static var errorColor: Color { AppColor.errorColor }
    static var warningColor: Color { AppColor.warningColor }
    static var successColor: Color { AppColor.successColor }

    // 文本色：主体文本与次级文本
    static var textPrimaryColor: Color { AppColor.textPrimaryColor }
    static var textSecondaryColor: Color { AppColor.textSecondaryColor }

    // 禁用态/占位色
    static var disabledColor: Color { AppColor.disabledColor }
}
