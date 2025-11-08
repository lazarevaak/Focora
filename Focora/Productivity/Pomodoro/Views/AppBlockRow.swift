//
//  AppBlockRow.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

internal import SwiftUI

struct AppBlockRow: View {
    let app: AppInfo
    let isBlocked: Bool
    let toggleAction: (Bool) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                toggleAction(!isBlocked)
            } label: {
                Image(systemName: isBlocked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isBlocked
                                     ? Color(red: 0.72, green: 0.82, blue: 0.93)
                                     : .white.opacity(0.6))
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)

            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .cornerRadius(4)
            }

            Text(app.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isBlocked
                      ? Color(red: 0.70, green: 0.80, blue: 0.92).opacity(0.15)
                      : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isBlocked
                                ? AnyShapeStyle(FocoraGradients.primary)
                                : AnyShapeStyle(Color.clear),
                                lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isBlocked)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleAction(!isBlocked)
        }
    }
}
