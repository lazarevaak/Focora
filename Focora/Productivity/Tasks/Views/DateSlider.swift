//
//  DateSlider.swift
//  Focora
//
//  Created by Alexandra Lazareva on 06.11.2025.
//

internal import SwiftUI

struct DateSlider: View {
    @Binding var selection: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Due Date")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(FocoraGradients.primary)
                    .opacity(0.15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(FocoraGradients.primary, lineWidth: 1.5)
                    )

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))

                    DatePicker("", selection: $selection, displayedComponents: [.date])
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(Color(red: 0.72, green: 0.82, blue: 0.93))
                        .frame(height: 30)
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 36)
            .animation(.easeInOut(duration: 0.25), value: selection)
        }
    }
}
