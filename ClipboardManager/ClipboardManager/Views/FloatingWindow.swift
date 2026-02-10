import SwiftUI
import AppKit

class FloatingWindowController: NSWindowController {
    private let normalSize = NSSize(width: 400, height: 600)
    private let compactSize = NSSize(width: 400, height: 60)
    private var isCompact = false

    convenience init(viewModel: ClipboardViewModel) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = NSLocalizedString("app.title", comment: "")
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false

        // 최대화 버튼 비활성화
        window.standardWindowButton(.zoomButton)?.isEnabled = false

        // 최소화 버튼 숨기기 (메뉴바 앱이므로 Dock으로 최소화되면 안됨)
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true

        window.center()

        // SwiftUI 뷰 설정
        let contentView = ClipboardHistoryView(viewModel: viewModel)
        window.contentView = NSHostingView(rootView: contentView)

        self.init(window: window)

        // ViewModel에 토글 클로저 전달
        viewModel.onToggleCompactMode = { [weak self] in
            self?.toggleCompactMode()
        }
    }

    func toggleCompactMode() {
        isCompact.toggle()

        guard let window = window else { return }

        let newSize = isCompact ? compactSize : normalSize
        let newFrame = NSRect(
            origin: window.frame.origin,
            size: newSize
        )

        // 애니메이션으로 크기 변경
        window.setFrame(newFrame, display: true, animate: true)
    }

    func toggle() {
        guard let window = window else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
