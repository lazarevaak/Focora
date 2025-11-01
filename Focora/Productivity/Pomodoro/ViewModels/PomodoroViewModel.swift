//
//  PomodoroViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

import Foundation
internal import Combine
import AppKit

final class PomodoroViewModel: ObservableObject {
    @Published var isVisible = false
    @Published var isRunning = false
    @Published var remainingTime: Int = 1500
    @Published var totalFocusTime: Int = 0
    @Published var activeTask: TaskModel?

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    func start(for task: TaskModel? = nil, duration: Int = 1500) {
        activeTask = task
        remainingTime = duration
        isRunning = true
        totalFocusTime += duration
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stop()
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
                set dark mode to true
            end tell
        end tell
        """
        _ = enabled ? script : nil
    }
}
