//
//  Shell.swift
//  Focora
//
//  Created by MacBoock on 23.10.2025.
//

import Foundation

@discardableResult
func runShell(_ path: String, args: [String]) -> Int32 {
    let task = Process()
    task.launchPath = path
    task.arguments = args
    do {
        try task.run()
        task.waitUntilExit()
        return task.terminationStatus
    } catch {
        print("Error: \(error)")
        return -1
    }
}

