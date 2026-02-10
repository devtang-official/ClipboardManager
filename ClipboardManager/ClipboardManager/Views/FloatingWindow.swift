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

        // 최대화/최소화 버튼 숨기기 (메뉴바 앱이므로 불필요)
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true

        // 화면 좌하단에 배치
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            
            // 좌하단: x는 왼쪽, y는 아래
            let padding: CGFloat = 20  // 가장자리에서 약간 떨어뜨림
            let x = screenFrame.minX + padding
            let y = screenFrame.minY + padding
            
            let origin = NSPoint(x: x, y: y)
            window.setFrameOrigin(origin)
        }

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

        // 윈도우 상단 위치를 고정하고 크기만 변경
        let currentFrame = window.frame
        let newOriginY = currentFrame.maxY - newSize.height  // 상단 고정
        let newFrame = NSRect(
            x: currentFrame.origin.x,
            y: newOriginY,
            width: newSize.width,
            height: newSize.height
        )

        // 부드러운 애니메이션으로 크기 변경
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25  // 0.25초 애니메이션
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        })
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
