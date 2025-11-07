//
//  TaskViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

import Foundation
import EventKit
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

    @Published var isPresentingSheet = false
    
    @Published var allTags: [TagModel] = []
    @Published var selectedTag: TagModel? = nil
    
    @Published var showCalendarPermissionAlert = false
    @Published var calendarEvents: [EKEvent] = []
    
    private let calendarManager = CalendarManager.shared

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

        for tagName in tags where !allTags.contains(where: { $0.name == tagName }) {
            allTags.append(TagModel(name: tagName))
        }
        saveTags()

        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day], from: newDueDate)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        newDueDate = calendar.date(from: components)!
        
        let newTask = TaskModel(
            title: trimmed,
            priority: newPriority,
            dueDate: newDueDate,
            tags: tags
        )

        tasks.append(newTask)
        saveTasks()

        newTitle = ""
        newTags = ""
        newPriority = .medium
        newDueDate = .now
    }

    func deleteTask(_ task: TaskModel) {
        if task.isSyncedWithCalendar, let eventId = task.calendarEventIdentifier {
            deleteFromCalendar(eventIdentifier: eventId)
        }
        
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        
        cleanupUnusedTags()
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
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601   
            let data = try encoder.encode(tasks)
            try data.write(to: tasksURL, options: .atomic)
        } catch {
            print("[TaskViewModel] Failed to save tasks: \(error)")
        }
    }

    func loadTasks() {
        guard FileManager.default.fileExists(atPath: tasksURL.path) else { return }
        do {
            let data = try Data(contentsOf: tasksURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601   
            tasks = try decoder.decode([TaskModel].self, from: data)
        } catch {
            print("[TaskViewModel] Failed to load tasks: \(error)")
        }
    }


    func saveTags() {
        do {
            let data = try JSONEncoder().encode(allTags)
            try data.write(to: tagsURL, options: .atomic)
        } catch {
            print("[TaskViewModel] Failed to save tags: \(error)")
        }
    }
    
    func cleanupUnusedTags() {
        let usedTagNames = Set(tasks.flatMap { $0.tags })

        let beforeCount = allTags.count
        allTags.removeAll { !usedTagNames.contains($0.name) }

        if allTags.count != beforeCount {
            saveTags()
            print("[TaskViewModel] Cleaned up unused tags.")
        }
    }


    func loadTags() {
        guard FileManager.default.fileExists(atPath: tagsURL.path) else { return }
        do {
            let data = try Data(contentsOf: tagsURL)
            allTags = try JSONDecoder().decode([TagModel].self, from: data)
        } catch {
            print("[TaskViewModel] Failed to load tags: \(error)")
        }
    }
    
    // MARK: - Calendar Integration
    
    func requestCalendarAccess() {
        Task {
            if #available(macOS 14.0, *) {
                let status = EKEventStore.authorizationStatus(for: .event)
                
                if status == .fullAccess {
                    return
                }
                
                if status == .denied || status == .restricted {
                    showCalendarPermissionAlert = true
                    return
                }
                
                let granted = await calendarManager.requestCalendarAccess()
                if !granted {
                    showCalendarPermissionAlert = true
                }
            } else {
                let status = EKEventStore.authorizationStatus(for: .event)
                
                if status == .authorized {
                    return
                }
                
                if status == .denied || status == .restricted {
                    showCalendarPermissionAlert = true
                    return
                }
                
                let granted = await calendarManager.requestCalendarAccess()
                if !granted {
                    showCalendarPermissionAlert = true
                }
            }
        }
    }
    
    func importFromCalendar() {
        guard calendarManager.hasCalendarAccess else {
            requestCalendarAccess()
            return
        }
        
        let events = calendarManager.fetchUpcomingEvents(daysAhead: 30)
        calendarEvents = events
        
        for event in events {
            let alreadyExists = tasks.contains { $0.calendarEventIdentifier == event.eventIdentifier }
            guard !alreadyExists else { continue }
            
            let task = TaskModel(
                title: event.title ?? "Untitled Event",
                priority: .medium,
                dueDate: event.startDate,
                tags: ["calendar"],
                calendarEventIdentifier: event.eventIdentifier,
                isSyncedWithCalendar: true
            )
            
            tasks.append(task)
        }
        
        saveTasks()
    }
    
    func exportToCalendar(_ task: TaskModel) {
        guard calendarManager.hasCalendarAccess else {
            requestCalendarAccess()
            return
        }
        
        guard !task.isSyncedWithCalendar else {
            print("Task already synced with calendar")
            return
        }
        
        let startDate = task.dueDate ?? Date()
        let duration: TimeInterval = 3600
        
        let notes = """
        Priority: \(task.priority.rawValue)
        Tags: \(task.tags.joined(separator: ", "))
        Created in Focora
        """
        
        let result = calendarManager.createEvent(
            title: task.title,
            startDate: startDate,
            duration: duration,
            notes: notes
        )
        
        switch result {
        case .success(let event):
            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[idx].calendarEventIdentifier = event.eventIdentifier
                tasks[idx].isSyncedWithCalendar = true
                saveTasks()
            }
            print("Task exported to calendar successfully")
            
        case .failure(let error):
            print("Failed to export task: \(error)")
        }
    }
    
    func deleteFromCalendar(eventIdentifier: String) {
        guard calendarManager.hasCalendarAccess else { return }
        
        let events = calendarManager.fetchUpcomingEvents(daysAhead: 365)
        if let event = events.first(where: { $0.eventIdentifier == eventIdentifier }) {
            _ = calendarManager.deleteEvent(event)
        }
    }
    
    func syncAllWithCalendar() {
        for task in tasks where !task.isSyncedWithCalendar && task.dueDate != nil {
            exportToCalendar(task)
        }
    }
}
