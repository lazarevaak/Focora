//
//  FocusableWindow.swift
//  Focora
//
//  Created by MacBoock on 31.10.2025.
//

import AppKit

final class FocusableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
