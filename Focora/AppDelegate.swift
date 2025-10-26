//
//  AppDelegate.swift
//  Focora
//
//  Created by MacBoock on 21.10.2025.
//

import AppKit
import SwiftUI
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let catalog = CommandCatalog()
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let contentView = LauncherView(isVisible: .constant(false))
            .environmentObject(catalog)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 100),
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

        window.contentView?.layoutSubtreeIfNeeded()
        let fittingHeight = hostingView.fittingSize.height
        window.setContentSize(NSSize(width: 600, height: fittingHeight))

        self.window = window

        HotKeyManager.shared.registerGlobalHotKey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey),
            action: { [weak self] in
                guard let self = self, let window = self.window else { return }
                if window.isVisible {
                    window.orderOut(nil)
                } else {
                    self.showWindow(window)
                }
            }
        )
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
