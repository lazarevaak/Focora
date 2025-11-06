//
//  PomodoroViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

import Foundation
internal import Combine
import AppKit

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

final class PomodoroViewModel: ObservableObject {
    @Published var isVisible = false
    @Published var isRunning = false
    @Published var remainingTime: Int = 1500
    @Published var totalFocusTime: Int = 0
    @Published var activeTask: TaskModel?

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var sessions: [PomodoroModel] = []

    init() {
        loadSessions()
        updateTotalFocusTime()
    }

    func start(for task: TaskModel? = nil, duration: Int = 1500) {
        activeTask = task
        remainingTime = duration
        isRunning = true
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stop()
                self.completeSession()
                self.notify()
            }
        }

        enableDoNotDisturb(true)
    }

    func stop() {
        timer?.invalidate()
        isRunning = false
        enableDoNotDisturb(false)
    }

    private func completeSession() {
        let session = PomodoroModel(
            taskId: activeTask?.id,
            duration: 1500 - remainingTime,
            startDate: Date().addingTimeInterval(TimeInterval(-remainingTime)),
            endDate: Date()
        )
        sessions.append(session)
        PomodoroStorage.append(session)
        updateTotalFocusTime()
    }

    private func loadSessions() {
        sessions = PomodoroStorage.load()
    }

    private func updateTotalFocusTime() {
        let today = Calendar.current.startOfDay(for: Date())
        totalFocusTime = sessions
            .filter { $0.startDate >= today }
            .reduce(0) { $0 + $1.duration }
    }

    private func notify() {
        let notification = NSUserNotification()
        notification.title = "Pomodoro Complete"
        notification.informativeText = "Take a break!"
        NSUserNotificationCenter.default.deliver(notification)
    }

    private func enableDoNotDisturb(_ enabled: Bool) {
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to \(enabled ? "true" : "false")
            end tell
        end tell
        """
        _ = NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
}

