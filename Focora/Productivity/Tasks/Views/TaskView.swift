//
//  TaskView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

internal import SwiftUI

struct TaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @EnvironmentObject var pomodoroVM: PomodoroViewModel

    @State private var mode: Mode = .add
    @State private var sortOrder: SortOrder = .newestFirst
    @State private var selectedTags: Set<TagModel> = []

    @State private var selectedTask: TaskModel?
    @State private var selectedDuration = 1500
    @State private var showDurationPicker = false

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
        .background(FocoraGradients.windowBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .strokeBorder(FocoraGradients.primary, lineWidth: 4)
            .opacity(0.9))
        .shadow(color: .black.opacity(0.4), radius: 25, y: 4)
        .sheet(isPresented: $showDurationPicker, onDismiss: {
            viewModel.isPresentingSheet = false
        }) {
            durationPicker
                .onAppear {
                    viewModel.isPresentingSheet = true
                }
                .presentationDetents([.fraction(0.3)])
                .alert("Calendar Access Required", isPresented: $viewModel.showCalendarPermissionAlert) {
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Please grant calendar access in System Settings to use calendar integration.")
                }
        }

    }
}

// MARK: - Subviews
private extension TaskView {

    var topBar: some View {
        HStack {
            Text("Task Manager")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FocoraGradients.primary)
            
            Spacer()

            ModePicker(selection: $mode)

            Button(action: { viewModel.importFromCalendar() }) {
                Image(systemName: "arrow.down.circle")
                    .foregroundStyle(FocoraGradients.primary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("Добавить задачи из календаря")

            Button(action: { viewModel.syncAllWithCalendar() }) {
                Image(systemName: "arrow.up.circle")
                    .foregroundStyle(FocoraGradients.primary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help("Добавить все задачи в календарь")
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(FocoraGradients.topBarBackground)
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mode == .add { inputSection } else { searchSection }
            Divider().background(Color.white.opacity(0.2))
            taskList
                .frame(maxHeight: .infinity)
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
                            colors: [
                                Color(red: 0.72, green: 0.82, blue: 0.93),
                                Color(red: 0.80, green: 0.75, blue: 0.90)
                            ],
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
        let baseColor = tag.color

        let tagGradient = LinearGradient(
            colors: [
                baseColor.opacity(0.9),
                baseColor.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        return Text(tag.name)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                        ? AnyShapeStyle(tagGradient)
                        : AnyShapeStyle(baseColor.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected
                                ? AnyShapeStyle(tagGradient)
                                : AnyShapeStyle(baseColor.opacity(0.1)),
                                lineWidth: 1.2
                            )
                    )
            )
            .foregroundColor(isSelected ? .black : baseColor)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isSelected { selectedTags.remove(tag) }
                    else { selectedTags.insert(tag) }
                }
            }
    }


    // MARK: - Search Section
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search tasks...", text: $viewModel.searchText)
                .textFieldStyle(DarkTextFieldStyle())

            Text("Found: \(filteredAndSortedTasks.count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(FocoraGradients.primary)


            HStack(spacing: 8) {
                SortPicker(sortOrder: $sortOrder)

                if !viewModel.allTags.isEmpty {
                    TagPicker(
                        selectedTag: $viewModel.selectedTag,
                        tags: viewModel.allTags
                    )
                }
            }
        }
    }


    // MARK: Task List
    var taskList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(filteredAndSortedTasks) { task in
                        taskItem(task)
                            .id(task.id)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: Filter + Sort
    var filteredAndSortedTasks: [TaskModel] {
        var result = viewModel.tasks

        if mode == .search && !viewModel.searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(viewModel.searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(viewModel.searchText) }
            }
        }

        if let tag = viewModel.selectedTag {
            result = result.filter { $0.tags.contains(tag.name) }
        }

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
        let isSelected = selectedTask?.id == task.id

        return HStack(alignment: .top, spacing: 10) {
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
                        FlowLayout(spacing: 6) {
                            ForEach(task.tags, id: \.self) { tagName in
                                if let tag = viewModel.allTags.first(where: { $0.name == tagName }) {
                                    Text(tag.name)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(tag.color.opacity(0.2))
                                        .foregroundColor(tag.color)
                                        .cornerRadius(4)
                                } else {
                                    Text(tagName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                    }


                }

                Text("Focus: \(pomodoroVM.totalFocusTime(for: task) / 60) min")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            if !task.isSyncedWithCalendar && task.dueDate != nil {
                Button {
                    viewModel.exportToCalendar(task)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.blue.opacity(0.8))
                }
                .buttonStyle(.plain)
                .help("Добавить в календарь")
            }

            Button(role: .destructive) {
                viewModel.deleteTask(task)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected
                    ? Color(red: 0.70, green: 0.80, blue: 0.92).opacity(0.15)
                    : Color.white.opacity(0.05)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? AnyShapeStyle(FocoraGradients.primary) : AnyShapeStyle(Color.clear),
                            lineWidth: 1.5
                        )
                )

        )
        .onTapGesture {
            if isSelected {
                showDurationPicker = true
            } else {
                selectedTask = task
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTask?.id)
    }

    var durationPicker: some View {
        VStack(spacing: 20) {
            Text("Select Focus Duration")
                .font(.headline)

            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { Double(selectedDuration) },
                        set: { selectedDuration = Int($0) }
                    ),
                    in: 60...3600,
                    step: 60
                )
                .tint(.purple)

                Text("Duration: \(formatDuration(selectedDuration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                Button("Cancel", role: .cancel) {
                    showDurationPicker = false
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)

                Button("Start Focus") {
                    guard let task = selectedTask else { return }
                    pomodoroVM.start(for: task, duration: selectedDuration)
                    showDurationPicker = false
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .onAppear {
            selectedDuration = 1500
        }
        .padding()
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(secs)s"
        } else {
            return "\(secs)s"
        }
    }
}


