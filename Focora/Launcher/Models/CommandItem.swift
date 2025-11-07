//
//  CommandItem.swift
//  Focora
//
//  Created by Alexandra Lazareva on 23.10.2025.
//

import Foundation
import AppKit

struct CommandItem: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let appIcon: NSImage?
    let title: String
    let keywords: [String]
    let run: () -> Void
    
    init(icon: String, title: String, keywords: [String], run: @escaping () -> Void) {
        self.icon = icon
        self.appIcon = nil
        self.title = title
        self.keywords = keywords
        self.run = run
    }
    
    init(appIcon: NSImage?, title: String, keywords: [String], run: @escaping () -> Void) {
        self.icon = ""
        self.appIcon = appIcon
        self.title = title
        self.keywords = keywords
        self.run = run
    }

    static func == (lhs: CommandItem, rhs: CommandItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

