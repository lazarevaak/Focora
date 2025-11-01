//
//  AppDelegate.swift
//  Focora
//
//  Created by Alexandra Lazareva on 21.10.2025.
//

import AppKit
internal import SwiftUI
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let catalog = LauncherViewModel()
    private let clipboardVM = ClipboardViewModel()
    private let taskManagerVM = TaskViewModel()
    private let pomodoroVM = PomodoroViewModel()

    private var launcherWindow: NSWindow?
    private var clipboardWindow: NSWindow?
    private var taskManagerWindow: NSWindow?
    private var pomodoroWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupLauncherWindow()
        setupHotKeys()
    }

    // MARK: - Setup Launcher Window
    private func setupLauncherWindow() {
        guard launcherWindow == nil else { return }

        let contentView = LauncherView(isVisible: .constant(false))
            .environmentObject(catalog)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 120),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)

        window.contentView = hostingView
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            hostingView.widthAnchor.constraint(equalToConstant: 600)
        ])

        launcherWindow = window
    }

    // MARK: - Setup Clipboard Window
    private func setupClipboardWindowIfNeeded() {
        guard clipboardWindow == nil else { return }

        let view = ClipboardView(viewModel: clipboardVM)
        let hosting = NSHostingController(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 360),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        window.level = .statusBar
        window.center()

        clipboardWindow = window
    }

    // MARK: - Setup Task Manager Window
    private func setupTaskManagerWindowIfNeeded() {
        guard taskManagerWindow == nil else { return }

        let view = TaskView(viewModel: taskManagerVM)
        let hosting = NSHostingController(rootView: view)
        
        let window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 120),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        window.level = .statusBar
        window.center()

        taskManagerWindow = window
    }

    // MARK: - Setup Pomodoro Window
    private func setupPomodoroWindowIfNeeded() {
        guard pomodoroWindow == nil else { return }

        let view = PomodoroView(viewModel: pomodoroVM)
        let hosting = NSHostingController(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 260),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        window.level = .statusBar
        window.center()

        pomodoroWindow = window
    }

    // MARK: - Window Appearance
    private func configureForCustomAppearance(_ window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.hasShadow = true

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 18
        window.contentView?.layer?.masksToBounds = true
    }

    // MARK: - Hotkeys
    private func setupHotKeys() {
        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey)
        ) { [weak self] in
            self?.toggleLauncher()
        }

        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_ANSI_V),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.toggleClipboard()
        }

        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_ANSI_T),
            modifiers: UInt32(cmdKey | optionKey)
        ) { [weak self] in
            self?.toggleTaskManager()
        }

        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_ANSI_P),
            modifiers: UInt32(cmdKey | optionKey)
        ) { [weak self] in
            self?.togglePomodoro()
        }
    }

    // MARK: - Toggle Windows
    private func toggleLauncher() {
        guard let window = launcherWindow else { return }
        window.isVisible ? window.orderOut(nil) : showWindow(window)
    }

    private func toggleClipboard() {
        setupClipboardWindowIfNeeded()
        guard let window = clipboardWindow else { return }

        if clipboardVM.isVisible {
            window.orderOut(nil)
            clipboardVM.isVisible = false
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            clipboardVM.isVisible = true
        }
    }

    private func toggleTaskManager() {
        setupTaskManagerWindowIfNeeded()
        guard let window = taskManagerWindow else { return }

        if taskManagerVM.isVisible {
            window.orderOut(nil)
            taskManagerVM.isVisible = false
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            taskManagerVM.isVisible = true
        }
    }

    private func togglePomodoro() {
        setupPomodoroWindowIfNeeded()
        guard let window = pomodoroWindow else { return }

        if pomodoroVM.isVisible {
            window.orderOut(nil)
            pomodoroVM.isVisible = false
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            pomodoroVM.isVisible = true
        }
    }

    // MARK: - Common Window Helpers
    private func showWindow(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let frame = window.frame
        let x = screen.visibleFrame.midX - frame.width / 2
        let y = screen.visibleFrame.midY - frame.height / 2
        window.setFrameOrigin(NSPoint(x: x, y: y))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.focusFirstTextField(in: window)
        }
    }

    private func focusFirstTextField(in window: NSWindow) {
        func findTextField(in view: NSView) -> NSTextField? {
            if let tf = view as? NSTextField { return tf }
            for sub in view.subviews {
                if let found = findTextField(in: sub) { return found }
            }
            return nil
        }

        if let textField = findTextField(in: window.contentView ?? NSView()) {
            window.makeFirstResponder(textField)
            textField.becomeFirstResponder()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }
}
