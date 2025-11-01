//
//  TaskModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

import Foundation

struct TaskModel: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var priority: Priority
    var dueDate: Date?
    var tags: [String]
    var isCompleted: Bool

    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        tags: [String] = [],
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.tags = tags
        self.isCompleted = isCompleted
    }
}
