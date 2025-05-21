// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  ColorList.swift
//  ClasstableWidgetExtension
//
//  Created by BenderBlog Rodriguez on 2024/2/29.
//

import Foundation
import SwiftUI

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, opacity: CGFloat(a) / 255)
    }
}

// Colors
var colors: [Color] = [
    Color(hexString: "#EF5350"),
    Color(hexString: "#EC407A"),
    Color(hexString: "#AB47BC"),
    Color(hexString: "#7E57C2"),
    Color(hexString: "#5C6BC0"),
    Color(hexString: "#42A5F5"),
    Color(hexString: "#29B6F6"),
    Color(hexString: "#26C6DA"),
    Color(hexString: "#26A69A"),
    Color(hexString: "#66BB6A"),
    Color(hexString: "#9CCC65"),
    Color(hexString: "#66BB6A"),
]

