//
//  ClipboardViewModel.swift
//  Focora
//
//  Created by Alexandra Lazareva on 29.10.2025.
//

import AppKit
internal import Combine

@MainActor
final class ClipboardViewModel: ObservableObject {
    @Published var history: [ClipboardItem] = []
    @Published var isVisible: Bool = false

    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        if let newString = pb.string(forType: .string), !newString.isEmpty {
            addToHistory(newString)
        }
    }

    private func addToHistory(_ string: String) {
        if history.first?.content == string { return }
        history.insert(ClipboardItem(content: string, date: Date()), at: 0)
        if history.count > 20 { history.removeLast() }
    }

    func paste(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(item.content, forType: .string)

        let src = CGEventSource(stateID: .combinedSessionState)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        vDown?.flags = .maskCommand
        let vUp = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        
        vUp?.flags = .maskCommand
        vDown?.post(tap: .cgAnnotatedSessionEventTap)
        vUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
}
