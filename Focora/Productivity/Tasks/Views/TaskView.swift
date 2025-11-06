//
//  TaskView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

internal import SwiftUI

struct TaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var mode: Mode = .add
    @State private var sortOrder: SortOrder = .newestFirst
    @State private var selectedTags: Set<TagModel> = [] // ✅ выбранные теги при создании

    enum Mode: String, CaseIterable {
        case add = "Add Task"
        case search = "Search"
    }

    enum SortOrder: String, CaseIterable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            content
        }
        .frame(width: 483, height: 560)
        .background(background)
        .cornerRadius(16)
        .overlay(borderOverlay)
        .shadow(color: .black.opacity(0.4), radius: 25, y: 4)
    }
}

// MARK: - Subviews
private extension TaskView {
    var topBar: some View {
        HStack {
            Text("Task Manager")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(topBarGradient)
            Spacer()
            Picker("", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(topBarBackground)
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mode == .add { inputSection } else { searchSection }
            Divider().background(Color.white.opacity(0.2))
            taskList
        }
        .padding(16)
    }

    // MARK: Add Section
    var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("New task...", text: $viewModel.newTitle)
                .frame(height: 30)
                .textFieldStyle(DarkTextFieldStyle())

            HStack {
                PrioritySlider(selection: $viewModel.newPriority)
                    .frame(width: 220)
                DateSlider(selection: $viewModel.newDueDate)
                    .frame(width: 220)
            }

            TextField("Tags (comma separated)", text: $viewModel.newTags)
                .textFieldStyle(DarkTextFieldStyle())

            // ✅ Выбор из прошлых тегов
            if !viewModel.allTags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select existing tags:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.allTags, id: \.id) { tag in
                                tagCapsule(tag)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Button(action: {
                // Добавляем выбранные теги к введённым вручную
                let manualTags = viewModel.newTags
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                let selectedTagNames = selectedTags.map(\.name)
                let combined = Array(Set(manualTags + selectedTagNames))

                viewModel.newTags = combined.joined(separator: ", ")
                viewModel.addTask()
                selectedTags.removeAll()
            }) {
                Text("Add Task")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.72, green: 0.82, blue: 0.93),
                                     Color(red: 0.80, green: 0.75, blue: 0.90)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(6)
                    .foregroundColor(.black)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Capsule Tag
    func tagCapsule(_ tag: TagModel) -> some View {
        let isSelected = selectedTags.contains(tag)

        return Text(tag.name)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected
                          ? .red
                          : Color.white.opacity(0.08))
            )
            .foregroundColor(isSelected ? .black : .white.opacity(0.9))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isSelected {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }
            }
    }

    // MARK: Search Section
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search tasks...", text: $viewModel.searchText)
                .textFieldStyle(DarkTextFieldStyle())

            HStack {
                Text("Found: \(filteredAndSortedTasks.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                .padding(3)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
            }

            if !viewModel.allTags.isEmpty {
                TagPicker(selectedTag: $viewModel.selectedTag, tags: viewModel.allTags)
            }
        }
    }

    // MARK: Task List
    var taskList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(filteredAndSortedTasks) { task in
                    taskItem(task)
                }
            }
        }
    }

    // MARK: Filter + Sort
    var filteredAndSortedTasks: [TaskModel] {
        var result = viewModel.tasks

        // Поиск
        if mode == .search && !viewModel.searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(viewModel.searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(viewModel.searchText) }
            }
        }

        // Фильтр по тегу
        if let tag = viewModel.selectedTag {
            result = result.filter { $0.tags.contains(tag.name) }
        }

        // Сортировка
        result.sort {
            guard let d1 = $0.dueDate, let d2 = $1.dueDate else { return false }
            switch sortOrder {
            case .newestFirst: return d1 > d2
            case .oldestFirst: return d1 < d2
            }
        }
        return result
    }

    // MARK: Task Item
    func taskItem(_ task: TaskModel) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { viewModel.toggleCompletion(for: task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted
                        ? Color(red: 0.72, green: 0.82, blue: 0.93)
                        : .white.opacity(0.6))
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {
                    Text("Priority: \(task.priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))

                    if let date = task.dueDate {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    if !task.tags.isEmpty {
                        Text(task.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
            }

            Spacer()

            Button(role: .destructive) {
                if let index = viewModel.tasks.firstIndex(of: task) {
                    viewModel.tasks.remove(at: index)
                    viewModel.saveTasks()
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Styles
private extension TaskView {
    var topBarGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.72, green: 0.82, blue: 0.93),
                Color(red: 0.80, green: 0.75, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var topBarBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.13, blue: 0.16),
                Color(red: 0.09, green: 0.10, blue: 0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var background: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.07, green: 0.08, blue: 0.10),
                Color(red: 0.12, green: 0.13, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color(red: 0.72, green: 0.82, blue: 0.93),
                        Color(red: 0.80, green: 0.75, blue: 0.90)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 4
            )
            .opacity(0.9)
    }
}



struct TagPicker: View {
    @Binding var selectedTag: TagModel?
    let tags: [TagModel]

    // Фирменный градиент
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.72, green: 0.82, blue: 0.93),
                Color(red: 0.80, green: 0.75, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Filter by tag")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.65))

            ZStack {
                // Фон с лёгким свечением
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(gradient, lineWidth: 1.2)
                    )

                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color(red: 0.78, green: 0.86, blue: 0.96))
                        .font(.system(size: 12, weight: .semibold))

                    Picker("", selection: $selectedTag) {
                        Text("All").tag(TagModel?.none)
                        ForEach(tags, id: \.id) { tag in
                            Text(tag.name).tag(TagModel?.some(tag))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(height: 26)
                    .colorScheme(.dark)
                    .tint(Color(red: 0.75, green: 0.80, blue: 0.94))
                }
                .padding(.horizontal, 8)
            }
            .frame(width: 180, height: 30)
        }
    }
}
