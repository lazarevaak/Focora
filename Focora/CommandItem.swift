//
//  CommandItem.swift
//  Focora
//
//  Created by MacBoock on 23.10.2025.
//

import Foundation

struct CommandItem: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let keywords: [String]
    let run: () -> Void

    static func == (lhs: CommandItem, rhs: CommandItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

