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
struct AppIdFailedError : Error {}

// Sync classtable data to the public place...
public class ApiImplementation: SaveToGroupIdSwiftApi {
    func saveToGroupId(data: FileToGroupID, completion: @escaping (Result<Bool, Error>) -> Void) {
        let fileManager = FileManager()
        do {
            let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: data.appid)
            if fileURL == nil {
                throw AppIdFailedError()
            }
            print("\(String(describing: fileURL?.absoluteString))")
            if fileManager.fileExists(atPath: fileURL!.absoluteString) {
               try! fileManager.removeItem(at: fileURL!)
            }
            try Data(data.data.utf8).write(
                to: fileURL!.appendingPathComponent(data.fileName),
                options: [.atomic,]
            )
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
        print("Write complete!")
        completion(.success(true))
    }
    
    func getHostLanguage() throws -> String {
        return "Swift"
    }
}
// #enddocregion swift-class
