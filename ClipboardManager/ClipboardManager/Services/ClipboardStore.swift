import Foundation
import AppKit
import Combine

class ClipboardStore: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private let maxItems = 100

    // 새 항목 추가
    func add(item: ClipboardItem) {
        // 중복 확인 (같은 내용이면 추가하지 않음)
        if isDuplicate(item) {
            return
        }

        // 맨 앞에 추가
        items.insert(item, at: 0)

        // 최대 개수 제한
        if items.count > maxItems {
            items.removeLast()
        }
    }

    // 항목 삭제
    func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    // 핀 토글
    func togglePin(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isPinned.toggle()
            sortItems()
        }
    }

    // 검색
    func search(query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return items }

        return items.filter { item in
            switch item.content {
            case .text(let text):
                return text.localizedCaseInsensitiveContains(query)
            case .url(let url):
                return url.absoluteString.localizedCaseInsensitiveContains(query)
            case .filePath(let url):
                return url.lastPathComponent.localizedCaseInsensitiveContains(query)
            case .image:
                return false
            }
        }
    }

    // 클립보드에 복사
    func copyToClipboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.content {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let image):
            pasteboard.writeObjects([image])
        case .filePath(let url):
            pasteboard.writeObjects([url as NSURL])
        case .url(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        }
    }

    // 중복 확인
    private func isDuplicate(_ newItem: ClipboardItem) -> Bool {
        guard let firstItem = items.first else { return false }

        switch (newItem.content, firstItem.content) {
        case (.text(let new), .text(let old)):
            return new == old
        case (.url(let new), .url(let old)):
            return new == old
        case (.filePath(let new), .filePath(let old)):
            return new == old
        default:
            return false
        }
    }

    // 정렬 (고정된 항목이 먼저, 그 다음 최신순)
    private func sortItems() {
        items.sort { item1, item2 in
            if item1.isPinned != item2.isPinned {
                return item1.isPinned
            }
            return item1.timestamp > item2.timestamp
        }
    }
}
