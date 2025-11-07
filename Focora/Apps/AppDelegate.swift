//
//  AppDelegate.swift
//  Focora
//
//  Created by Alexandra Lazareva on 21.10.2025.
//

import AppKit
internal import SwiftUI
import Carbon.HIToolbox
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let catalog = LauncherViewModel()
    private let clipboardVM = ClipboardViewModel()
    private let taskManagerVM = TaskViewModel()
    private let pomodoroVM = PomodoroViewModel()

    private var launcherWindow: NSWindow?
    private var clipboardWindow: NSWindow?
    private var taskManagerWindow: NSWindow?
    private var pomodoroWindow: NSWindow?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSApp.windows.forEach { $0.close() }
    }
    
    // MARK: - App entry
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupLauncherWindow()
        setupHotKeys()
        setupNotifications()
    }

    // MARK: - Notification setup
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("⚠️ Notification authorization failed: \(error)")
            } else if !granted {
                print("⚠️ Notifications not granted by user.")
            }
        }
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
        window.delegate = self
        
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

        let window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 360),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        
        window.contentView?.layer?.cornerRadius = 18
        window.contentView?.layer?.masksToBounds = true
        
        window.level = .statusBar
        window.center()
        window.delegate = self

        clipboardWindow = window
    }

    // MARK: - Setup Task Manager Window
    private func setupTaskManagerWindowIfNeeded() {
        guard taskManagerWindow == nil else { return }

        // ✅ передаём общий PomodoroViewModel через environmentObject
        let view = TaskView(viewModel: taskManagerVM)
            .environmentObject(pomodoroVM)
        let hosting = NSHostingController(rootView: view)

        let window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 120),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        
        window.contentView?.layer?.cornerRadius = 18
        window.contentView?.layer?.masksToBounds = true
        
        window.level = .statusBar
        window.center()
        window.delegate = self

        taskManagerWindow = window
    }

    // MARK: - Setup Pomodoro Window
    private func setupPomodoroWindowIfNeeded() {
        guard pomodoroWindow == nil else { return }

        let view = PomodoroView(viewModel: pomodoroVM)
        let hosting = NSHostingController(rootView: view)

        let window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 260),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configureForCustomAppearance(window)
        window.contentViewController = hosting
        
        window.contentView?.layer?.cornerRadius = 18
        window.contentView?.layer?.masksToBounds = true
        
        window.level = .statusBar
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.delegate = self

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
        window.isVisible ? window.orderOut(nil) : showWindow(window, position: .center)
    }

    private func toggleClipboard() {
        setupClipboardWindowIfNeeded()
        guard let window = clipboardWindow else { return }

        if clipboardVM.isVisible {
            window.orderOut(nil)
            clipboardVM.isVisible = false
        } else {
            showWindow(window, position: .topRight)
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
            showWindow(window, position: .bottomLeft)
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
            showWindow(window, position: .bottomRight)
            pomodoroVM.isVisible = true
        }
    }

    // MARK: - Common Window Helpers
    private enum WindowPosition {
        case center
        case topRight
        case bottomRight
        case bottomLeft

        func origin(for windowSize: CGSize, in screenFrame: CGRect, padding: CGFloat = 24) -> NSPoint {
            switch self {
            case .center:
                return NSPoint(
                    x: screenFrame.midX - windowSize.width / 2,
                    y: screenFrame.midY - windowSize.height / 2
                )
            case .topRight:
                return NSPoint(
                    x: screenFrame.maxX - windowSize.width - padding,
                    y: screenFrame.maxY - windowSize.height - padding
                )
            case .bottomRight:
                return NSPoint(
                    x: screenFrame.maxX - windowSize.width - padding,
                    y: screenFrame.minY + padding
                )
            case .bottomLeft:
                return NSPoint(
                    x: screenFrame.minX + padding,
                    y: screenFrame.minY + padding
                )
            }
        }
    }
    
    private func showWindow(_ window: NSWindow, position: WindowPosition) {
        window.contentViewController?.view.layoutSubtreeIfNeeded()

        guard let screen = window.screen ?? NSScreen.main else { return }

        let contentSize = window.contentViewController?.view.fittingSize ?? window.frame.size
        let targetFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize))
        let origin = position.origin(for: targetFrame.size, in: screen.visibleFrame)

        window.setFrame(NSRect(origin: origin, size: targetFrame.size), display: false)

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
    
    func windowDidResignKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let newKey = NSApp.keyWindow,
               [self.launcherWindow,
                self.clipboardWindow,
                self.taskManagerWindow,
                self.pomodoroWindow].contains(where: { $0 === newKey }) {
                return
            }

            switch window {
            case self.launcherWindow:
                window.orderOut(nil)

            case self.clipboardWindow:
                self.clipboardWindow?.orderOut(nil)
                self.clipboardVM.isVisible = false

            case self.taskManagerWindow:
                if self.taskManagerVM.isPresentingSheet {
                    return
                }
                self.taskManagerWindow?.orderOut(nil)
                self.taskManagerVM.isVisible = false

            case self.pomodoroWindow:
                self.pomodoroWindow?.orderOut(nil)
                self.pomodoroVM.isVisible = false

            default:
                break
            }
        }
    }

}
