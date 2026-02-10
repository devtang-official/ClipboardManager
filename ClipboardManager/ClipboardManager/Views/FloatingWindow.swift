import SwiftUI
import AppKit

class FloatingWindowController: NSWindowController {
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
        window.center()

        // SwiftUI 뷰 설정
        let contentView = ClipboardHistoryView(viewModel: viewModel)
        window.contentView = NSHostingView(rootView: contentView)

        self.init(window: window)
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
