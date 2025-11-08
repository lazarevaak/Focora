//
//  PomodoroTabPicker.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

internal import SwiftUI

struct PomodoroTabPicker: View {
    @Binding var selection: PomodoroView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PomodoroView.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .background(
                            ZStack {
                                if selection == tab {
                                    FocoraGradients.primary
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Color.white.opacity(0.08)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        )
                        .foregroundColor(selection == tab ? .black : .white.opacity(0.9))
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
