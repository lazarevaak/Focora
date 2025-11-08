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
    @Published var searchText: String = ""

    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var isPasting = false
    
    private let storageURL: URL = {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Focora", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("clipboard.json")
    }()

    init() {
        loadHistory()
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        
        guard !isPasting else { return }
        
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
        saveHistory()
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("[ClipboardViewModel] Failed to save history: \(error)")
        }
    }

    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("[ClipboardViewModel] Failed to load history: \(error)")
        }
    }
    
    var filteredHistory: [ClipboardItem] {
        guard !searchText.isEmpty else { return history }
        
        let query = searchText.lowercased()
        return history.filter { item in
            item.content.lowercased().contains(query)
        }
    }

    func paste(_ item: ClipboardItem) {
        isPasting = true
        
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(item.content, forType: .string)
        
        lastChangeCount = pb.changeCount

        let src = CGEventSource(stateID: .combinedSessionState)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        vDown?.flags = .maskCommand
        let vUp = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        
        vUp?.flags = .maskCommand
        vDown?.post(tap: .cgAnnotatedSessionEventTap)
        vUp?.post(tap: .cgAnnotatedSessionEventTap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
           self?.isPasting = false
       }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }
}
