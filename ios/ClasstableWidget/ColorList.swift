//
//  ColorList.swift
//  ClasstableWidgetExtension
//
//  Created by sprt on 2024/2/29.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
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
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// Colors
var colors: [UIColor] = [
    UIColor(hexString: "#EF5350"),
    UIColor(hexString: "#EC407A"),
    UIColor(hexString: "#AB47BC"),
    UIColor(hexString: "#7E57C2"),
    UIColor(hexString: "#5C6BC0"),
    UIColor(hexString: "#42A5F5"),
    UIColor(hexString: "#29B6F6"),
    UIColor(hexString: "#26C6DA"),
    UIColor(hexString: "#26A69A"),
    UIColor(hexString: "#66BB6A"),
    UIColor(hexString: "#9CCC65"),
    UIColor(hexString: "#66BB6A"),
]

