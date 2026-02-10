import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem?
    var floatingWindowController: FloatingWindowController?
    var viewModel: ClipboardViewModel?
    var hotkeyManager: HotkeyManager?
    var toggleMenuItem: NSMenuItem?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // 기본 앱 메뉴 커스터마이징 (앱 시작 전에 설정)
        setupMainMenu()
    }

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
        menu.delegate = self

        // 윈도우 토글 메뉴
        toggleMenuItem = NSMenuItem(
            title: NSLocalizedString("menu.show_window", comment: ""),
            action: #selector(toggleWindow),
            keyEquivalent: "v"
        )
        toggleMenuItem?.keyEquivalentModifierMask = [.command, .shift]
        toggleMenuItem?.target = self
        menu.addItem(toggleMenuItem!)

        menu.addItem(NSMenuItem.separator())

        // 종료 메뉴
        let quitMenuItem = NSMenuItem(
            title: NSLocalizedString("menu.quit", comment: ""),
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)

        // 오른쪽 클릭 메뉴 설정
        statusItem?.menu = menu

        // 왼쪽 클릭은 직접 toggleWindow 호출
        if let button = statusItem?.button {
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMainMenu() {
        guard let mainMenu = NSApp.mainMenu else { return }
        
        // 첫 번째 메뉴 아이템(앱 메뉴)의 서브메뉴 가져오기
        guard let appMenuItem = mainMenu.items.first,
              let appMenu = appMenuItem.submenu else { return }
        
        // About 메뉴 아이템 찾아서 우리 커스텀 메서드로 연결
        for item in appMenu.items {
            if item.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:)) {
                item.action = #selector(showAbout)
                item.target = self
                break
            }
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
        // 앱 아이콘 로드
        let appIcon = NSApp.applicationIconImage ?? NSImage()
        appIcon.size = NSSize(width: 128, height: 128)
        
        // 슬로건
        let tagline = NSLocalizedString("app.tagline", comment: "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let credits = NSMutableAttributedString()
        credits.append(NSAttributedString(string: "\n\n"))
        credits.append(NSAttributedString(
            string: tagline,
            attributes: [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.secondaryLabelColor,
                .paragraphStyle: paragraphStyle
            ]
        ))
        
        let options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: NSLocalizedString("app.title", comment: ""),
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            .credits: credits,
            .applicationIcon: appIcon
        ]
        
        NSApp.orderFrontStandardAboutPanel(options: options)
        NSApp.activate(ignoringOtherApps: true)
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
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        updateMenuItems()
    }
    
    private func updateMenuItems() {
        let isWindowVisible = floatingWindowController?.window?.isVisible ?? false
        
        if isWindowVisible {
            toggleMenuItem?.title = NSLocalizedString("menu.hide_window", comment: "")
        } else {
            toggleMenuItem?.title = NSLocalizedString("menu.show_window", comment: "")
        }
    }
}
