//
//  TaskView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 02.11.2025.
//

internal import SwiftUI

struct TaskView: View {
    @ObservedObject var viewModel: TaskViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
            content
        }
        .frame(width: 520, height: 400)
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
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(topBarBackground)
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            inputSection
            Divider().background(Color.white.opacity(0.2))
            taskList
        }
        .padding(16)
    }

    // MARK: Input Section
    var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("New task...", text: $viewModel.newTitle)
                .frame(height: 30)
                .textFieldStyle(DarkTextFieldStyle())

            HStack {
                Picker("Priority", selection: $viewModel.newPriority) {
                    ForEach(TaskModel.Priority.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                DatePicker(
                    "Due date",
                    selection: $viewModel.newDueDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
            }

            TextField("Tags (comma separated)", text: $viewModel.newTags)
                .textFieldStyle(DarkTextFieldStyle())

            Button(action: viewModel.addTask) {
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

    // MARK: Task List
    var taskList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.tasks) { task in
                    taskItem(task)
                }
            }
        }
    }

    func taskItem(_ task: TaskModel) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { viewModel.toggleCompletion(for: task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .white.opacity(0.6))
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
