// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import SwiftUI

/// 实际小组件共用的文字层级；截图式教学预览由原图决定字号。
enum WatchWidgetDesignTokens {
    static let circularPrimary = Font.system(size: 12, weight: .semibold)
    static let circularSecondary = Font.system(size: 8, weight: .medium)
    static let circularProgressHeading = Font.system(size: 7, weight: .medium)
    static let circularSpacing: CGFloat = 2
    static let cornerPrimary = Font.system(size: 12, weight: .bold, design: .rounded)
    static let cornerTime = Font.system(size: 10, weight: .regular, design: .rounded)
    static let rectangularInfo = Font.system(size: 16, weight: .regular)
}
