import Foundation
import Carbon

class HotkeyManager {
    var onHotkeyPressed: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    // 단축키 ID (고유값)
    private let hotkeyID = EventHotKeyID(signature: OSType(0x48545259), id: 1) // 'HTRY' + 1

    deinit {
        unregisterHotkey()
    }

    func registerHotkey() {
        // 이미 등록되어 있으면 먼저 해제
        if hotKeyRef != nil {
            unregisterHotkey()
        }

        // Command + Shift + V (keycode 9)
        let keyCode: UInt32 = 9 // V key
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

        // Event Handler 등록
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, event, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }

            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()

            // HotKey ID 확인
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(event,
                                          EventParamName(kEventParamDirectObject),
                                          EventParamType(typeEventHotKeyID),
                                          nil,
                                          MemoryLayout<EventHotKeyID>.size,
                                          nil,
                                          &hotKeyID)

            if status == noErr && hotKeyID.id == manager.hotkeyID.id {
                DispatchQueue.main.async {
                    manager.onHotkeyPressed?()
                }
                return noErr
            }

            return OSStatus(eventNotHandledErr)
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        // HotKey 등록
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode,
                                        modifiers,
                                        hotkeyID,
                                        GetApplicationEventTarget(),
                                        0,
                                        &hotKeyRef)

        if status == noErr {
            self.hotKeyRef = hotKeyRef
            print("✅ Hotkey registered: Command + Shift + V")
        } else {
            print("❌ Failed to register hotkey: \(status)")
        }
    }

    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
}
