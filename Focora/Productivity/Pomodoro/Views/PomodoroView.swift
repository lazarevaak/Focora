//
//  PomodoroView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

internal import SwiftUI

struct PomodoroView: View {
    @ObservedObject var viewModel: PomodoroViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.7), .blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Pomodoro Timer")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                if let task = viewModel.activeTask {
                    Text("Focus: \(task.title)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Text(formatTime(viewModel.remainingTime))
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)

                HStack(spacing: 40) {
                    Button(viewModel.isRunning ? "Stop" : "Start") {
                        viewModel.isRunning ? viewModel.stop() : viewModel.start()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Reset") {
                        viewModel.stop()
                        viewModel.remainingTime = 1500
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Divider().background(Color.white.opacity(0.5))

                Text("Total focus: \(viewModel.totalFocusTime / 60) min today")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)

                Spacer()
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
