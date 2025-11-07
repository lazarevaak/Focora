//
//  SortPicker.swift
//  Focora
//
//  Created by Alexandra Lazareva on 07.11.2025.
//

internal import SwiftUI

struct SortPicker: View {
    @Binding var sortOrder: TaskView.SortOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sort by date")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.65))

            ZStack {
                // фон
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(FocoraGradients.primary, lineWidth: 1.2)
                    )

                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .foregroundColor(Color(red: 0.78, green: 0.86, blue: 0.96))
                        .font(.system(size: 12, weight: .semibold))

                    Picker("", selection: $sortOrder) {
                        ForEach(TaskView.SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue)
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
            .frame(width: 180, height: 35)
        }
    }
}

