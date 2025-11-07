//
//  PomodoroViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

import Foundation
internal import Combine
import UserNotifications

/// MARK: - ViewModel
final class PomodoroViewModel: ObservableObject {
    @Published var isVisible = false
    @Published var isRunning = false
    @Published var remainingTime: Int = 1500   // ✅ 25 минут по умолчанию
    @Published var totalFocusTime: Int = 0
    @Published var activeTask: TaskModel?
    @Published var maxDuration: Int = 3600     // ✅ максимум 1 час

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var sessions: [PomodoroModel] = []
    private var sessionDuration: Int = 1500    // ✅ тоже 25 минут по умолчанию

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            } else {
                print("Notifications permission granted:", granted)
            }
        }

        loadSessions()
        updateTotalFocusTime()
    }

    // MARK: - Start Pomodoro
    func start(for task: TaskModel? = nil, duration: Int = 1500) {
        activeTask = task
        sessionDuration = min(duration, maxDuration)
        remainingTime = sessionDuration
        isRunning = true
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                if self.remainingTime % 60 == 0 {
                    self.updateTotalFocusTime()
                }
            } else {
                print("Pomodoro finished — triggering notify()")
                self.stop()
                self.completeSession()
                self.notify()
            }
        }

        enableDoNotDisturb(true)
    }

    // MARK: - Stop Pomodoro
    func stop() {
        timer?.invalidate()
        isRunning = false
        updateTotalFocusTime()
        enableDoNotDisturb(false)
    }

    // MARK: - Complete Session
    private func completeSession() {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(TimeInterval(-sessionDuration))

        let session = PomodoroModel(
            taskId: activeTask?.id,
            duration: sessionDuration,
            startDate: startDate,
            endDate: endDate
        )

        sessions.append(session)
        PomodoroStorage.append(session)
        updateTotalFocusTime()
    }

    // MARK: - Load & Stats
    private func loadSessions() {
        sessions = PomodoroStorage.load()
    }

    private func updateTotalFocusTime() {
        let today = Calendar.current.startOfDay(for: Date())
        let saved = sessions.filter { $0.startDate >= today }.reduce(0) { $0 + $1.duration }
        let activeElapsed = isRunning ? (sessionDuration - remainingTime) : 0
        totalFocusTime = saved + activeElapsed
    }

    func totalFocusTime(for task: TaskModel) -> Int {
        sessions.filter { $0.taskId == task.id }.reduce(0) { $0 + $1.duration }
    }

    // MARK: - Notifications
    private func notify() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            let content = UNMutableNotificationContent()
            content.title = "Pomodoro Complete"
            content.body = "Take a short break ☕️"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error { print("Notification error:", error) }
                else { print("Pomodoro notification scheduled.") }
            }
        }
    }


    // MARK: - Do Not Disturb
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
