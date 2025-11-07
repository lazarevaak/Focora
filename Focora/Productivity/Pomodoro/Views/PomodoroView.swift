//
//  PomodoroView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

internal import SwiftUI

internal struct PomodoroView: View {
    @ObservedObject var viewModel: PomodoroViewModel

    var body: some View {
        ZStack {
            FocoraGradients.lightPrimary
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // MARK: - Header
                Text("Pomodoro")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 16)
                    .shadow(color: .white.opacity(0.4), radius: 4, y: 2)

                // MARK: - Timer circle
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

                    Circle()
                        .trim(from: 0, to: CGFloat(1 - Double(viewModel.remainingTime) / 1500))
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    Color(red: 0.82, green: 0.78, blue: 0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.25), value: viewModel.remainingTime)

                    VStack(spacing: 8) {
                        Text(formatTime(viewModel.remainingTime))
                            .font(.system(size: 54, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .white.opacity(0.3), radius: 4, y: 2)

                        if let task = viewModel.activeTask {
                            Text(task.title)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        } else {
                            Text("No active task")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .frame(width: 220, height: 220)

                // MARK: - Buttons
                HStack(spacing: 32) {
                    Button {
                        viewModel.isRunning ? viewModel.stop() : viewModel.start()
                    } label: {
                        Label(viewModel.isRunning ? "Pause" : "Start",
                              systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.headline)
                            .frame(width: 120, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.stop()
                        viewModel.remainingTime = 1500
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(width: 120, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Total Focus
                VStack(spacing: 6) {
                    Divider().background(Color.white.opacity(0.5))
                        .padding(.horizontal, 40)

                    Text("Total focus today:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(viewModel.totalFocusTime / 60) min")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding(.horizontal, 28)
            .frame(width: 340, height: 520)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(FocoraGradients.lightPrimary.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.7), lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 4)
            )
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
