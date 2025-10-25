//
//  HotKeyManager.swift
//  Focora
//
//  Created by MacBoock on 23.10.2025.
//

import Carbon.HIToolbox
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var action: (() -> Void)?

    func registerGlobalHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        action: @escaping () -> Void
    ) {
        self.action = action
        let hotKeyID = EventHotKeyID(signature: OSType(fourChar("FOCR")), id: 1)
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
            let manager = Unmanaged<HotKeyManager>
                .fromOpaque(userData!)
                .takeUnretainedValue()
            manager.action?()
            return noErr
        }, 1, [eventSpec], Unmanaged.passUnretained(self).toOpaque(), &eventHandlerRef)

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref) }
        if let handler = eventHandlerRef { RemoveEventHandler(handler) }
        hotKeyRef = nil
        eventHandlerRef = nil
    }
}

@inline(__always)
func fourChar(_ s: String) -> UInt32 {
    var result: UInt32 = 0
    for scalar in s.unicodeScalars.prefix(4) {
        result = (result << 8) + scalar.value
    }
    return result
}
