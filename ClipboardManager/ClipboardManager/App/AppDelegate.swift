import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var floatingWindowController: FloatingWindowController?
    var viewModel: ClipboardViewModel?
    var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // ViewModel 초기화
        viewModel = ClipboardViewModel()

        // 메뉴바 아이템 생성
        setupMenuBar()

        // 플로팅 윈도우 생성
        if let viewModel = viewModel {
            floatingWindowController = FloatingWindowController(viewModel: viewModel)
            // 앱 시작 시 윈도우 표시
            floatingWindowController?.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }

        // 글로벌 단축키 설정 (Command + Shift + V)
        setupHotkey()

        // 메인 윈도우 숨기기
        NSApp.windows.forEach { window in
            if window.className == "SwiftUI.AppKitWindow" {
                window.close()
            }
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(toggleWindow)
            button.target = self
        }

        // 메뉴 생성
        let menu = NSMenu()

        menu.addItem(NSMenuItem(
            title: NSLocalizedString("menu.show_window", comment: ""),
            action: #selector(toggleWindow),
            keyEquivalent: ""
        ))

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(
            title: NSLocalizedString("menu.quit", comment: ""),
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        // 오른쪽 클릭 메뉴 설정
        statusItem?.menu = menu

        // 왼쪽 클릭은 직접 toggleWindow 호출
        if let button = statusItem?.button {
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupHotkey() {
        hotkeyManager = HotkeyManager()
        hotkeyManager?.onHotkeyPressed = { [weak self] in
            self?.toggleWindow()
        }
        hotkeyManager?.registerHotkey()
    }

    @objc private func toggleWindow() {
        floatingWindowController?.toggle()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
