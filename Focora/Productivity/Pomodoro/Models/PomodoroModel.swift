//
//  PomodoroModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

import Foundation

struct PomodoroModel: Identifiable, Codable {
    let id: UUID
    let taskId: UUID?
    var duration: Int
    var startDate: Date
    var endDate: Date?

    init(
        id: UUID = UUID(),
        taskId: UUID? = nil,
        duration: Int,
        startDate: Date = Date(),
        endDate: Date? = nil
    ) {
        self.id = id
        self.taskId = taskId
        self.duration = duration
        self.startDate = startDate
        self.endDate = endDate
    }
}
