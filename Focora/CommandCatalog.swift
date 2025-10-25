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
    @Published var items: [CommandItem] = []

    init() {
        items = [
            CommandItem(icon: "SafariIcon", title: "Open Safari", keywords: ["safari", "browser", "apple"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
                    let config = NSWorkspace.OpenConfiguration()
                    NSWorkspace.shared.openApplication(at: url, configuration: config)
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
                    let config = NSWorkspace.OpenConfiguration()
                    NSWorkspace.shared.openApplication(at: url, configuration: config)
                }
            },

            CommandItem(icon: "XcodeIcon", title: "Open Xcode", keywords: ["xcode", "ide", "apple", "development"]) {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") {
                    let config = NSWorkspace.OpenConfiguration()
                    NSWorkspace.shared.openApplication(at: url, configuration: config)
                }
            }
        ]
    }
}
