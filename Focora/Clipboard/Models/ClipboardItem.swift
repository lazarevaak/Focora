//
//  ClipboardItem.swift
//  Focora
//
//  Created by Alexandra Lazareva on 29.10.2025.
//

import Foundation

struct ClipboardItem: Identifiable, Hashable, Codable {
    let id: UUID
    let content: String
    let date: Date
    
    init(content: String, date: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
    }
}
