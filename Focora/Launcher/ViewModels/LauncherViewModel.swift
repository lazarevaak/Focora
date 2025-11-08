//
//  LauncherViewModel.swift
//  Focora
//
//  Created by MacBoock on 28.10.2025.
//

internal import SwiftUI
import AppKit
internal import Combine

@MainActor
final class LauncherViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var commands: [CommandItem] = []
    @Published var apps: [CommandItem] = []
    
    init() {
        loadStaticCommands()
        Task { await scanApplications() }
    }
    
    // MARK: - Search commands
    func searchCommands(for query: String) -> [CommandItem] {
        guard !query.isEmpty else { return [] }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return [
            CommandItem(icon: "GoogleChromeIcon", title: "Search in Google", keywords: []) {
                if let searchURL = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
                    if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
                        NSWorkspace.shared.open([searchURL], withApplicationAt: chromeURL, configuration: NSWorkspace.OpenConfiguration())
                    } else {
                        NSWorkspace.shared.open(searchURL)
                    }
                }
            },
            CommandItem(icon: "YandexIcon", title: "Search in Yandex", keywords: []) {
                if let searchURL = URL(string: "https://yandex.ru/search/?text=\(encodedQuery)") {
                    if let yandexURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "ru.yandex.desktop.yandex-browser") {
                        NSWorkspace.shared.open([searchURL], withApplicationAt: yandexURL, configuration: NSWorkspace.OpenConfiguration())
                    } else {
                        NSWorkspace.shared.open(searchURL)
                    }
                }
            },
            CommandItem(icon: "SafariIcon", title: "Search in Safari", keywords: []) {
                if let searchURL = URL(string: "https://www.google.com/search?q=\(encodedQuery)"),
                   let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
                    NSWorkspace.shared.open([searchURL], withApplicationAt: safariURL, configuration: NSWorkspace.OpenConfiguration())
                }
            },
            CommandItem(icon: "ChatGPTIcon", title: "Search in ChatGPT", keywords: []) {
                if let searchURL = URL(string: "https://chat.openai.com/?q=\(encodedQuery)") {
                    if let chatGPTURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.openai.chat") {
                        NSWorkspace.shared.open([searchURL], withApplicationAt: chatGPTURL, configuration: NSWorkspace.OpenConfiguration())
                    } else {
                        NSWorkspace.shared.open(searchURL)
                    }
                }
            }
        ]
    }
    
    // MARK: - Filtering
    var filteredApps: [CommandItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return apps
            .compactMap { item -> (CommandItem, Int)? in
                let score = fuzzyScore(for: q, in: [item.title.lowercased()] + item.keywords.map { $0.lowercased() })
                return score > 0 ? (item, score) : nil
            }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
    
    // MARK: - Command loading
    private func loadStaticCommands() {
        commands = [
            CommandItem(icon: "SafariIcon", title: "Open Safari", keywords: ["safari", "browser", "apple"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
                    NSWorkspace.shared.openApplication(at: url, configuration: .init())
                }
            },
            CommandItem(icon: "GithubIcon", title: "Open GitHub", keywords: ["github", "site", "code"]) {
                if let url = URL(string: "https://github.com") {
                    NSWorkspace.shared.open(url)
                }
            },
            CommandItem(icon: "YandexIcon", title: "Open Yandex", keywords: ["yandex", "search", "browser"]) {
                if let url = URL(string: "https://yandex.ru") {
                    NSWorkspace.shared.open(url)
                }
            },
            CommandItem(icon: "GoogleChromeIcon", title: "Open Google Chrome", keywords: ["chrome", "browser", "google"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
                    NSWorkspace.shared.openApplication(at: url, configuration: .init())
                }
            },
            CommandItem(icon: "ChatGPTIcon", title: "Open ChatGPT", keywords: ["chatgpt", "gpt", "ai", "openai"]) {
                if let url = URL(string: "https://chat.openai.com") {
                    if let chatGPTURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.openai.chat") {
                        NSWorkspace.shared.openApplication(at: chatGPTURL, configuration: .init())
                    } else {
                        NSWorkspace.shared.open(url)
                    }
                }
            },
            CommandItem(icon: "XcodeIcon", title: "Open Xcode", keywords: ["xcode", "ide", "apple", "development"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") {
                    NSWorkspace.shared.openApplication(at: url, configuration: .init())
                }
            },
            CommandItem(icon: "PomodoroIcon", title: "Pomodoro", keywords: ["pomodoro", "timer", "focus"]) {
                NotificationCenter.default.post(name: NSNotification.Name("ShowPomodoro"), object: nil)
            },
            CommandItem(icon: "TaskManagerIcon", title: "Task Manager", keywords: ["tasks", "todo", "manager"]) {
                NotificationCenter.default.post(name: NSNotification.Name("ShowTaskManager"), object: nil)
            },
            CommandItem(icon: "ClipboardIcon", title: "Clipboard", keywords: ["clipboard", "copy", "paste"]) {
                NotificationCenter.default.post(name: NSNotification.Name("ShowClipboard"), object: nil)
            }
        ]
    }
    
    // MARK: - App scanning
    private func scanApplications() async {
        let fm = FileManager.default
        let dirs = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        ]
        
        var found: [CommandItem] = []
        for dir in dirs {
            guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else { continue }
            for case let appURL as URL in enumerator {
                guard appURL.pathExtension == "app" else { continue }
                let name = appURL.deletingPathExtension().lastPathComponent
                let keywords = [name.lowercased()]
                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                let item = CommandItem(appIcon: icon, title: name, keywords: keywords) {
                    NSWorkspace.shared.openApplication(at: appURL, configuration: .init())
                }
                found.append(item)
                enumerator.skipDescendants()
            }
        }
        apps = found.sorted { $0.title.lowercased() < $1.title.lowercased() }
    }
    
    // MARK: - Fuzzy scoring
    private func fuzzyScore(for query: String, in texts: [String]) -> Int {
        var best = 0
        for text in texts {
            var score = 0
            var index = text.startIndex
            for char in query {
                if let found = text[index...].firstIndex(of: char) {
                    score += 1
                    index = text.index(after: found)
                } else {
                    score = 0
                    break
                }
            }
            best = max(best, score)
        }
        return best
    }
}
