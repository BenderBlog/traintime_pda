// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
//
//  SaveToGroupIdApiImplementation.swift
//  Runner
//
//  Created by sprt on 2024/1/18.
//

import Foundation

// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}
struct AppIdFailedError: Error {}

// Sync classtable data to the public place...
public class ApiImplementation: SaveToGroupIdSwiftApi {
    func saveToGroupId(data: FileToGroupID, completion: @escaping (Result<Bool, Error>) -> Void) {
        let fileManager = FileManager.default

        do {
            guard let containerURL = fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: data.appid
            ) else {
                throw AppIdFailedError()
            }

            let targetURL = containerURL.appendingPathComponent(data.fileName, isDirectory: false)
            print("App Group container: \(containerURL.path)")
            print("Target file: \(targetURL.path)")

            // Only replace target file, never delete the whole container directory.
            if fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.removeItem(at: targetURL)
            }

            // Write with protection option directly (more reliable than only setAttributes).
            try Data(data.data.utf8).write(
                to: targetURL,
                options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
            )

            // Keep explicit setAttributes as a second guarantee.
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: targetURL.path
            )

            // Debug: verify the protection value just written.
            let attrs = try fileManager.attributesOfItem(atPath: targetURL.path)
            if let protection = attrs[.protectionKey] as? FileProtectionType {
                print("File protection for \(data.fileName): \(protection.rawValue)")
            } else if let protectionRaw = attrs[.protectionKey] {
                print("File protection for \(data.fileName): \(protectionRaw)")
            } else {
                print("File protection for \(data.fileName): <nil> (simulator may not reflect Data Protection)")
            }

            print("Write complete!")
            completion(.success(true))
        } catch is AppIdFailedError {
            completion(.failure(FlutterError(
                code: "AppIdFailedError",
                message: "Can't get the folder with appid",
                details: "You should check whether your app group id spells wrong."
            )))
        } catch {
            completion(.failure(FlutterError(
                code: "WriteFailedError",
                message: "\(error)",
                details: error.localizedDescription
            )))
        }
    }

    func getHostLanguage() throws -> String {
        return "Swift"
    }
}
// #enddocregion swift-class
