//
//  TaskViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

import Foundation
internal import Combine
internal import SwiftUI

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var newTitle: String = ""
    @Published var newPriority: TaskModel.Priority = .medium
    @Published var newTags: String = ""
    @Published var newDueDate: Date = .now
    @Published var isVisible: Bool = false

    private let storageURL: URL = {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let path = folder.appendingPathComponent("Focora")
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        return path.appendingPathComponent("tasks.json")
    }()

    init() {
        loadTasks()
    }

    func addTask() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let tags = newTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let new = TaskModel(
            title: trimmed,
            priority: newPriority,
            dueDate: newDueDate,
            tags: tags
        )

        tasks.append(new)
        saveTasks()

        newTitle = ""
        newTags = ""
        newPriority = .medium
        newDueDate = .now
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    func toggleCompletion(for task: TaskModel) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted.toggle()
            saveTasks()
        }
    }

    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("⚠️ [TaskViewModel] Failed to save tasks: \(error)")
        }
    }

    func loadTasks() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let decoded = try JSONDecoder().decode([TaskModel].self, from: data)
            tasks = decoded
        } catch {
            print("⚠️ [TaskViewModel] Failed to load tasks: \(error)")
        }
    }
}
