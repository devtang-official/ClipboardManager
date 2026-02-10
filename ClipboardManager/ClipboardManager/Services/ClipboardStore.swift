import Foundation
import AppKit
import Combine

class ClipboardStore: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private let maxItems = 100

    // 새 항목 추가
    func add(item: ClipboardItem) {
        // 중복 항목 찾기 및 삭제
        if let existingIndex = findDuplicateIndex(item) {
            items.remove(at: existingIndex)
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
        case .image(let image, _):  // fileName 무시
            pasteboard.writeObjects([image])
        case .filePath(let url):
            pasteboard.writeObjects([url as NSURL])
        case .url(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        }
    }

    // 중복 확인 로직 개선
    private func findDuplicateIndex(_ newItem: ClipboardItem) -> Int? {
        return items.firstIndex { existingItem in
            switch (newItem.content, existingItem.content) {
            case (.text(let new), .text(let old)):
                return new == old
            case (.url(let new), .url(let old)):
                return new == old
            case (.filePath(let new), .filePath(let old)):
                return new == old
            // 이미지는 비교하지 않음 (항상 새로 추가)
            default:
                return false
            }
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
