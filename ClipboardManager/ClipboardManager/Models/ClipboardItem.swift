import Foundation
import AppKit

struct ClipboardItem: Identifiable {
    let id: UUID
    let content: ClipboardContent
    let type: ClipboardItemType
    let timestamp: Date
    var isPinned: Bool

    enum ClipboardContent {
        case text(String)
        case image(NSImage, fileName: String?)
        case filePath(URL)
        case url(URL)
    }

    init(content: ClipboardContent, isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
        self.isPinned = isPinned

        // content에 따라 type 자동 설정
        switch content {
        case .text:
            self.type = .text
        case .image:
            self.type = .image
        case .filePath:
            self.type = .filePath
        case .url:
            self.type = .url
        }
    }
}
