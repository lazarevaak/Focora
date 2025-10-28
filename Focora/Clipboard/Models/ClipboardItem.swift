//
//  ClipboardItem.swift
//  Focora
//
//  Created by Alexandra Lazareva on 29.10.2025.
//

import Foundation

struct ClipboardItem: Identifiable, Hashable {
    let id = UUID()
        let content: String
        let date: Date
}
