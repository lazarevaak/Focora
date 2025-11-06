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
    // MARK: - Published properties
    @Published var tasks: [TaskModel] = []
    @Published var newTitle: String = ""
    @Published var newPriority: TaskModel.Priority = .medium
    @Published var newTags: String = ""
    @Published var newDueDate: Date = .now
    @Published var isVisible: Bool = false
    @Published var searchText: String = ""
    @Published var allTags: [TagModel] = []        // ✅ список тегов
    @Published var selectedTag: TagModel? = nil    // ✅ фильтрация по тегу

    // MARK: - Storage
    private let storageFolder: URL = {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Focora", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    private var tasksURL: URL { storageFolder.appendingPathComponent("tasks.json") }
    private var tagsURL: URL { storageFolder.appendingPathComponent("tags.json") }

    // MARK: - Init
    init() {
        loadTasks()
        loadTags()
    }

    // MARK: - CRUD
    func addTask() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let tags = newTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // добавляем новые теги в список, если их ещё нет
        for tagName in tags where !allTags.contains(where: { $0.name == tagName }) {
            allTags.append(TagModel(name: tagName))
        }
        saveTags()

        let newTask = TaskModel(
            title: trimmed,
            priority: newPriority,
            dueDate: newDueDate,
            tags: tags
        )

        tasks.append(newTask)
        saveTasks()

        // Reset input fields
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
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }

    // MARK: - Persistence
    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: tasksURL, options: .atomic)
        } catch {
            print("⚠️ [TaskViewModel] Failed to save tasks: \(error)")
        }
    }

    func loadTasks() {
        guard FileManager.default.fileExists(atPath: tasksURL.path) else { return }
        do {
            let data = try Data(contentsOf: tasksURL)
            let decoded = try JSONDecoder().decode([TaskModel].self, from: data)
            tasks = decoded
        } catch {
            print("⚠️ [TaskViewModel] Failed to load tasks: \(error)")
        }
    }

    func saveTags() {
        do {
            let data = try JSONEncoder().encode(allTags)
            try data.write(to: tagsURL, options: .atomic)
        } catch {
            print("⚠️ [TaskViewModel] Failed to save tags: \(error)")
        }
    }

    func loadTags() {
        guard FileManager.default.fileExists(atPath: tagsURL.path) else { return }
        do {
            let data = try Data(contentsOf: tagsURL)
            allTags = try JSONDecoder().decode([TagModel].self, from: data)
        } catch {
            print("⚠️ [TaskViewModel] Failed to load tags: \(error)")
        }
    }
}
