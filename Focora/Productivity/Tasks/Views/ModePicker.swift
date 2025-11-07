//
//  ModePicker.swift
//  Focora
//
//  Created by Alexandra Lazareva on 07.11.2025.
//

internal import SwiftUI

struct ModePicker: View {
    @Binding var selection: TaskView.Mode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TaskView.Mode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .background(
                            ZStack {
                                if selection == mode {
                                    FocoraGradients.primary
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Color.white.opacity(0.08)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        )
                        .foregroundColor(selection == mode ? .black : .white.opacity(0.9))
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(FocoraGradients.primary, lineWidth: 1.2)
        )
        .frame(width: 220)
    }
}
