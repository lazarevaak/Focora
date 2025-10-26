//
//  CommandCatalog.swift
//  Focora
//
//  Created by MacBoock on 23.10.2025.
//

import SwiftUI
import Combine
import AppKit

final class CommandCatalog: ObservableObject {
    // Отдельно команды и приложения
    @Published var commands: [CommandItem] = []
    @Published var apps: [CommandItem] = []

    init() {
        // 1️⃣ Статические команды (всегда видны)
        self.commands = [
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
            CommandItem(icon: "XcodeIcon", title: "Open Xcode", keywords: ["xcode", "ide", "apple", "development"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") {
                    NSWorkspace.shared.openApplication(at: url, configuration: .init())
                }
            }
        ]

        // 2️⃣ Асинхронно загружаем установленные приложения
        Task.detached(priority: .background) {
            let foundApps = self.scanInstalledApplications()
            await MainActor.run {
                self.apps = foundApps.sorted { $0.title.lowercased() < $1.title.lowercased() }
            }
        }
    }

    // MARK: - Сканирование установленных приложений
    private func scanInstalledApplications() -> [CommandItem] {
        let fm = FileManager.default
        let appDirs: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        ]

        var foundApps: [CommandItem] = []

        for dir in appDirs {
            guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else { continue }

            for case let appURL as URL in enumerator {
                guard appURL.pathExtension == "app" else { continue }

                let name = appURL.deletingPathExtension().lastPathComponent
                let keywords = [name.lowercased()]
                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                icon.size = NSSize(width: 48, height: 48)

                let item = CommandItem(
                    icon: "",
                    title: name,
                    keywords: keywords
                ) {
                    NSWorkspace.shared.openApplication(at: appURL, configuration: .init())
                }

                foundApps.append(item)
                enumerator.skipDescendants()
            }
        }

        return foundApps
    }
}
