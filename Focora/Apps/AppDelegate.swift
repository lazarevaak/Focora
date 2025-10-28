//
//  AppDelegate.swift
//  Focora
//
//  Created by Alexandra Lazareva on 21.10.2025.
//
import AppKit
import SwiftUI
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let catalog = LauncherViewModel()
    private let clipboardVM = ClipboardViewModel()

    private var launcherWindow: NSWindow?
    private var clipboardWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupLauncherWindow()
        setupHotKeys()
    }

    // MARK: - Setup windows
    private func setupLauncherWindow() {
        let contentView = LauncherView(isVisible: .constant(false))
            .environmentObject(catalog)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 120),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = hostingView
        window.isMovableByWindowBackground = true

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            hostingView.widthAnchor.constraint(equalToConstant: 600)
        ])

        launcherWindow = window
    }

    // MARK: - Hotkeys
    private func setupHotKeys() {
        // Лаунчер: Option + Space
        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey)
        ) { [weak self] in
            self?.toggleWindow(self?.launcherWindow)
        }

        // Буфер обмена: Cmd + Shift + V
        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_ANSI_V),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.toggleClipboard()
        }
    }

    // MARK: - Toggle windows
    private func toggleWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            showWindow(window)
        }
    }

    private func toggleClipboard() {
        if clipboardVM.isVisible {
            clipboardWindow?.orderOut(nil)
            clipboardVM.isVisible = false
        } else {
            let view = ClipboardView(viewModel: clipboardVM)
            let hosting = NSHostingController(rootView: view)
            let window = NSWindow(contentViewController: hosting)
            window.styleMask = [.titled, .closable, .fullSizeContentView]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .statusBar
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            clipboardWindow = window
            clipboardVM.isVisible = true
        }
    }

    private func showWindow(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let frame = window.frame
        let x = screen.visibleFrame.midX - frame.width / 2
        let y = screen.visibleFrame.midY - frame.height / 2
        window.setFrameOrigin(NSPoint(x: x, y: y))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(window.contentView)
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }
}
