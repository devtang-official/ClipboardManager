import Foundation
import Carbon

class HotkeyManager {
    // TODO: KeyboardShortcuts SPM 라이브러리 추가 후 구현
    // 현재는 스텁으로만 구현

    var onHotkeyPressed: (() -> Void)?

    func registerHotkey() {
        // TODO: Command + Shift + V 단축키 등록
        print("Hotkey registration - TODO")
    }

    func unregisterHotkey() {
        // TODO: 단축키 해제
        print("Hotkey unregistration - TODO")
    }
}
