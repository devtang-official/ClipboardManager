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

        // About 메뉴
        menu.addItem(NSMenuItem(
            title: NSLocalizedString("menu.about", comment: ""),
            action: #selector(showAbout),
            keyEquivalent: ""
        ))

        menu.addItem(NSMenuItem.separator())

        // 윈도우 토글 메뉴
        let toggleMenuItem = NSMenuItem(
            title: NSLocalizedString("menu.show_window", comment: ""),
            action: #selector(toggleWindow),
            keyEquivalent: "v"
        )
        toggleMenuItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(toggleMenuItem)

        menu.addItem(NSMenuItem.separator())

        // 종료 메뉴
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

    @objc private func showAbout() {
        // 플로팅 윈도우 완전히 숨김
        let wasVisible = floatingWindowController?.window?.isVisible ?? false
        floatingWindowController?.window?.orderOut(nil)

        // 슬로건 텍스트 준비
        let tagline = NSLocalizedString("app.tagline", comment: "")
        let credits = NSMutableAttributedString()

        // 위에 공간 추가
        credits.append(NSAttributedString(string: "\n\n"))

        // 슬로건 추가 (가운데 정렬)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        credits.append(NSAttributedString(
            string: tagline,
            attributes: [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.secondaryLabelColor,
                .paragraphStyle: paragraphStyle
            ]
        ))

        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: NSLocalizedString("app.title", comment: ""),
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            .credits: credits,
            .applicationIcon: NSApp.applicationIconImage ?? NSImage()
        ])
        NSApp.activate(ignoringOtherApps: true)

        // About 창이 닫히면 플로팅 윈도우 복원 (3초 후, 원래 보였다면)
        if wasVisible {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.floatingWindowController?.window?.makeKeyAndOrderFront(nil)
            }
        }
    }

    @objc private func toggleWindow() {
        floatingWindowController?.toggle()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // Dock 아이콘 클릭 시 윈도우 표시
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // 보이는 윈도우가 없으면 윈도우 표시
            floatingWindowController?.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }
}
