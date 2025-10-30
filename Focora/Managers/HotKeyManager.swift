//
//  HotKeyManager.swift
//  Focora
//
//  Created by Alexandra Lazareva on 23.10.2025.
//

import Carbon.HIToolbox
import AppKit

final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var actions: [UInt32: () -> Void] = [:]
    private var eventHandlerRef: EventHandlerRef?

    private var currentID: UInt32 = 1

    func registerGlobalHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        action: @escaping () -> Void
    ) {
        let id = currentID
        currentID += 1

        let hotKeyID = EventHotKeyID(signature: OSType(fourChar("FOCR")), id: id)
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        actions[id] = action

        // Устанавливаем обработчик один раз
        if eventHandlerRef == nil {
            InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData!)
                    .takeUnretainedValue()

                if let action = manager.actions[hotKeyID.id] {
                    action()
                }

                return noErr
            }, 1, [eventSpec], Unmanaged.passUnretained(self).toOpaque(), &eventHandlerRef)
        }

        var hotKeyRef: EventHotKeyRef?
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)

        if let ref = hotKeyRef {
            hotKeyRefs[id] = ref
        }
    }

    func unregister() {
        for ref in hotKeyRefs.values {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()
        actions.removeAll()

        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
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
