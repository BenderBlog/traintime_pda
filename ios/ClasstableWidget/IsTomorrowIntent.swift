//
//  IsTomorrowIntent.swift
//  ClasstableWidgetExtension
//
//  Created by BenderBlog Rodriguez on 2024/3/1.
//  SPDX-License-Identifier: MPL-2.0
//

import Foundation
import AppIntents

@available(iOS 17.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *)
struct IsTomorrowManager {
    static var value = false
}

@available(iOS 17.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *)
struct IsTomorrowIntent: AppIntent {
    
    static var title: LocalizedStringResource = "IsTomorrow Task"
    static var description: IntentDescription = IntentDescription("IsTomorrow Task")
    
    init() { }
    
    func perform() async throws -> some IntentResult {
        IsTomorrowManager.value = !IsTomorrowManager.value
        return .result()
    }
}
