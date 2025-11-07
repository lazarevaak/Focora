//
//  PomodoroStorage.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 07.11.2025.
//

import Foundation

// MARK: - Storage
enum PomodoroStorage {
    private static var storageURL: URL {
        let container = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = container.appendingPathComponent("Focora", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("pomodoro.json")
    }

    static func load() -> [PomodoroModel] {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([PomodoroModel].self, from: data) else {
            return []
        }
        return decoded
    }

    static func save(_ sessions: [PomodoroModel]) {
        if let data = try? JSONEncoder().encode(sessions) {
            try? data.write(to: storageURL)
        }
    }

    static func append(_ session: PomodoroModel) {
        var sessions = load()
        sessions.append(session)
        save(sessions)
    }
}
