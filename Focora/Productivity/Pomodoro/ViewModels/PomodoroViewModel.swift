//
//  PomodoroViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

import Foundation
internal import SwiftUI
internal import Combine
@preconcurrency import UserNotifications
import AppKit

@MainActor
final class PomodoroViewModel: ObservableObject {
    // MARK: - Pomodoro Core
    @Published var isVisible = false
    @Published var isRunning = false
    @Published var remainingTime: Int = 1500       // 25 минут по умолчанию
    @Published var totalFocusTime: Int = 0
    @Published var activeTask: TaskModel?
    @Published var maxDuration: Int = 3600         // максимум 1 час

    // MARK: - Deep Focus
    @Published var isDeepFocusEnabled = false
    @Published var blockedApps: Set<String> = []
    @Published var availableApps: [AppInfo] = []
    @Published var blockedWebsites: [String] = []
    @Published var newWebsite: String = ""

    // MARK: - Private
    private var timer: Timer?
    private var focusMonitorTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var sessions: [PomodoroModel] = []
    @Published private(set) var sessionDuration: Int = 1500

    // MARK: - Init
    init() {
        blockedApps = AppBlockStorage.load()
        
        $blockedApps
            .dropFirst()
            .sink { newValue in
                AppBlockStorage.save(newValue)
            }
            .store(in: &cancellables)
        
        // Разрешения для уведомлений
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            } else {
                print("Notifications permission granted:", granted)
            }
        }

        // Асинхронное сканирование приложений
        Task { scanApplications() }

        loadSessions()
        updateTotalFocusTime()
    }
    
    // MARK: - Reset Pomodoro
    func reset() {
        timer?.invalidate()
        isRunning = false
        remainingTime = 1500
        sessionDuration = 1500
        activeTask = nil
        enableDoNotDisturb(false)
        
        if isDeepFocusEnabled {
            applyDeepFocus(false)
        }

        print("[Pomodoro] Reset to default state")
    }


    // MARK: - Stop Pomodoro
    func stop() {
        timer?.invalidate()
        isRunning = false
        updateTotalFocusTime()
        enableDoNotDisturb(false)

        // Отключаем Deep Focus
        if isDeepFocusEnabled {
            applyDeepFocus(false)
        }
    }

    // MARK: - Complete Session
    private func completeSession() {
        guard let taskId = activeTask?.id else { return }

        let endDate = Date()
        let actualDuration = sessionDuration - remainingTime
        let startDate = endDate.addingTimeInterval(TimeInterval(-actualDuration))

        let session = PomodoroModel(
            taskId: taskId,
            duration: actualDuration,
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
            print("[Pomodoro] Notification status:", settings.authorizationStatus.rawValue)

            guard settings.authorizationStatus == .authorized else {
                print("[Pomodoro] Notifications not authorized")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Pomodoro Complete"
            content.body = "Take a short break ☕️"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: trigger)

            DispatchQueue.main.async {
                center.add(request) { error in
                    if let error {
                        print("[Pomodoro] Notification error:", error.localizedDescription)
                    } else {
                        print("[Pomodoro] Notification successfully scheduled.")
                    }
                }
            }
        }
    }


    // MARK: - Deep Focus
    func toggleAppBlock(_ app: String, _ isBlocked: Bool) {
        if isBlocked {
            blockedApps.insert(app)
        } else {
            blockedApps.remove(app)
        }
    }
    
    // MARK: - Deep Focus
    private func applyDeepFocus(_ enable: Bool) {
        if enable {
            requestAutomationPermissionIfNeeded()
            quitBlockedApps()
            focusMonitorTimer?.invalidate()
            focusMonitorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }

                Task { @MainActor in
                    self.quitBlockedApps()
                }
            }

        } else {
            focusMonitorTimer?.invalidate()
            focusMonitorTimer = nil
        }
    }
    
    private func requestAutomationPermissionIfNeeded() {
        print("Checking Automation permission...")
        let testScript = """
        tell application "System Events"
            display dialog "Focora automation test — if this dialog shows, permissions work." buttons {"OK"} default button "OK"
        end tell
        """

        var errorDict: NSDictionary?
        if let script = NSAppleScript(source: testScript) {
            script.executeAndReturnError(&errorDict)
            if let errorDict {
                print("AppleScript error:", errorDict)
            } else {
                print("Automation permission confirmed or granted.")
            }
        } else {
            print("Failed to create AppleScript for permission test.")
        }
    }

    private func quitBlockedApps() {
        for appName in blockedApps {
            if let app = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == appName }) {
                app.terminate()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if app.isTerminated == false {
                        app.forceTerminate()
                    }
                }
            } else {
                let script = """
                tell application "\(appName)"
                    quit
                end tell
                """
                var errorDict: NSDictionary?
                if let appleScript = NSAppleScript(source: script) {
                    appleScript.executeAndReturnError(&errorDict)
                    if let errorDict {
                        print("AppleScript fallback error for \(appName): \(errorDict)")
                    } else {
                        print("AppleScript quit command sent to \(appName)")
                    }
                }
            }
        }
    }
    
    // MARK: - Toggle Pomodoro
    func toggleRunning(for task: TaskModel? = nil, duration: Int = 1500) {
        if isRunning {
            stop()
            return
        }

        if activeTask == nil, let newTask = task {
            activeTask = newTask
            sessionDuration = min(duration, maxDuration)
            remainingTime = sessionDuration
        } else if activeTask == nil { return }

        isRunning = true
        enableDoNotDisturb(true)

        if isDeepFocusEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.applyDeepFocus(true)
            }
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                    if self.remainingTime % 60 == 0 {
                        self.updateTotalFocusTime()
                    }
                } else {
                    self.timer?.invalidate()
                    self.isRunning = false

                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.remainingTime = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.completeSession()
                        self.notify()
                        self.reset()
                    }
                }
            }
        }
    }

    private func scanApplications() {
        let fm = FileManager.default
        let dirs = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        ]
        
        var found: [AppInfo] = []
        
        for dir in dirs {
            guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else { continue }
            for case let appURL as URL in enumerator {
                guard appURL.pathExtension == "app" else { continue }
                let name = appURL.deletingPathExtension().lastPathComponent
                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                icon.size = NSSize(width: 24, height: 24)
                found.append(AppInfo(name: name, icon: icon))
                enumerator.skipDescendants()
            }
        }

        let ignored = ["Finder", "Dock", "System Settings", "Terminal", "Activity Monitor"]
        let unique = Array(Set(found)).filter { !ignored.contains($0.name) }.sorted { $0.name < $1.name }

        Task { @MainActor in
            self.availableApps = unique
        }
    }


    // MARK: - Do Not Disturb
    private func enableDoNotDisturb(_ enabled: Bool) {
        let shortcut = enabled ? "Enable DND" : "Disable DND"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["run", shortcut]
        do {
            try process.run()
            print("[Pomodoro] Focus mode toggled successfully via shortcuts CLI.")
        } catch {
            print("[Pomodoro] Error running shortcut:", error.localizedDescription)
        }
    }
}
