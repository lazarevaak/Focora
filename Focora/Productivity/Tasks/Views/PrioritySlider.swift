//
//  PrioritySlider.swift
//  Focora
//
//  Created by Alexandra Lazareva on 06.11.2025.
//

internal import SwiftUI

struct PrioritySlider: View {
    @Binding var selection: TaskModel.Priority

    private let priorities: [TaskModel.Priority] = [.low, .medium, .high]

    var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.72, green: 0.82, blue: 0.93),
                Color(red: 0.80, green: 0.75, blue: 0.90)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Priority")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 6) {
                ForEach(priorities, id: \.self) { priority in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                selection == priority
                                ? AnyShapeStyle(gradient)
                                : AnyShapeStyle(Color.white.opacity(0.08))
                            )
                            .animation(.easeInOut(duration: 0.25), value: selection)

                        Text(priority.rawValue)
                            .font(.system(size: 12, weight: selection == priority ? .semibold : .regular))
                            .foregroundColor(selection == priority ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 8)
                    }
                    .frame(height: 26)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selection = priority
                        }
                    }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}
