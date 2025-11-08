//
//  AppBlockStorage.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

import Foundation

enum AppBlockStorage {
    private static var storageURL: URL {
        let container = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = container.appendingPathComponent("Focora", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("blocked_apps.json")
    }

    static func load() -> Set<String> {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return []
        }
        return decoded
    }

    static func save(_ blocked: Set<String>) {
        if let data = try? JSONEncoder().encode(blocked) {
            try? data.write(to: storageURL)
        }
    }
}
