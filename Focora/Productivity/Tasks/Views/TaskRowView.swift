//
//  TaskRowView.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

internal import SwiftUI

struct TaskRowView: View {
    let task: TaskModel
    let isSelected: Bool
    let allTags: [TagModel]
    let totalFocusTime: Int
    let onToggleCompletion: () -> Void
    let onDelete: () -> Void
    let onExport: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onToggleCompletion) {
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
                        TaskTagsView(tags: task.tags, allTags: allTags)
                    }
                }

                Text("Focus: \(totalFocusTime / 60) min")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            if !task.isSyncedWithCalendar && task.dueDate != nil {
                Button(action: onExport) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.trailing, 4)
                }
                .buttonStyle(.plain)
                .help("Добавить задачу в календарь")
            }

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected
                      ? Color(red: 0.70, green: 0.80, blue: 0.92).opacity(0.15)
                      : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? AnyShapeStyle(FocoraGradients.primary)
                                           : AnyShapeStyle(Color.clear),
                                lineWidth: 1.5)
                )
        )
    }
}
