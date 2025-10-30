//
//  ClipboardView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 29.10.2025.
//

import SwiftUI

struct ClipboardView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom top bar
            HStack {
                Text("Clipboard History")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.72, green: 0.82, blue: 0.93),
                                Color(red: 0.80, green: 0.75, blue: 0.90)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.13, blue: 0.16),
                        Color(red: 0.09, green: 0.10, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // MARK: - Scroll content
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.history) { item in
                        Button {
                            viewModel.paste(item)
                            viewModel.isVisible = false
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.content)
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
                                    .lineLimit(2)
                                Text(item.date.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 500, height: 360)
        .background(background)
        .cornerRadius(16)
        .overlay(borderOverlay)
        .shadow(color: .black.opacity(0.4), radius: 25, y: 4)
    }

    // MARK: - Background style (как фон на слайде)
    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.07, green: 0.08, blue: 0.10),
                Color(red: 0.12, green: 0.13, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Gradient border (как цвет текста Focora)
    private var borderOverlay: some View {
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
