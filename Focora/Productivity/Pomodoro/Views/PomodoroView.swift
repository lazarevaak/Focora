//
//  PomodoroView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 01.11.2025.
//

internal import SwiftUI

internal struct PomodoroView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @State private var selectedTab: Tab = .timer

    enum Tab: String, CaseIterable {
        case timer = "Timer"
        case settings = "Focus Settings"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            content
        }
        .frame(width: 483, height: 560)
        .background(FocoraGradients.windowBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(FocoraGradients.primary, lineWidth: 4)
                .opacity(0.9)
        )
        .shadow(color: .black.opacity(0.4), radius: 25, y: 4)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Text("Pomodoro")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FocoraGradients.primary)
            Spacer()
            PomodoroTabPicker(selection: $selectedTab)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(FocoraGradients.topBarBackground)
    }

    // MARK: - Main content
    private var content: some View {
        VStack(spacing: 20) {
            if selectedTab == .timer {
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Spacer()
                        totalFocusBar
                    }
                    timerContent
                }
            } else {
                focusSettings
            }
            Spacer()
        }
        .padding(16)
    }


    // MARK: - Timer
    private var timerContent: some View {
        VStack(spacing: 28) {
            timerCircle
            timerControls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 240, height: 240)

            Circle()
                .trim(from: 0,
                      to: CGFloat(1 - Double(viewModel.remainingTime) / Double(viewModel.sessionDuration)))
                .stroke(
                    FocoraGradients.primary,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: viewModel.remainingTime)

            VStack(spacing: 8) {
                Text(formatTime(viewModel.remainingTime))
                    .font(.system(size: 54, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                if let task = viewModel.activeTask {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }


    // MARK: - Timer Controls
    private var timerControls: some View {
        HStack(spacing: 16) {
            if let _ = viewModel.activeTask {
                Button(viewModel.isRunning ? "Pause" : "Continue") {
                    viewModel.toggleRunning(for: viewModel.activeTask)
                }
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 120, height: 36)
                .background(FocoraGradients.primary)
                .cornerRadius(6)
                .foregroundColor(.black)
                .buttonStyle(.plain)

                Button("Reset") {
                    viewModel.reset()
                }
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 120, height: 36)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
                .foregroundColor(.white.opacity(0.9))
                .buttonStyle(.plain)
            } else {
                EmptyView()
            }
        }
    }


    // MARK: - Focus Settings
    private var focusSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Deep Focus Mode")
                .font(.title3.bold())
                .foregroundColor(.white)

            Toggle("Enable Deep Focus", isOn: $viewModel.isDeepFocusEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .white))
                .foregroundColor(.white)

            if viewModel.isDeepFocusEnabled {
                Divider().background(Color.white.opacity(0.15))

                Text("Blocked Apps")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
                    .padding(.bottom, 6)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.availableApps) { app in
                            AppBlockRow(
                                app: app,
                                isBlocked: viewModel.blockedApps.contains(app.name),
                                toggleAction: { viewModel.toggleAppBlock(app.name, $0) }
                            )
                        }
                    }
                    .padding(.bottom, 1)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }


    // MARK: - Total Focus Bar
    private var totalFocusBar: some View {
        VStack(spacing: 6) {
            Text("Total Focus Today")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(FocoraGradients.primary)
                    .font(.system(size: 13, weight: .medium))

                Text(formatDuration(viewModel.totalFocusTime))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
        .animation(.easeInOut, value: viewModel.totalFocusTime)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, secs)
        } else {
            return "\(secs)s"
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
