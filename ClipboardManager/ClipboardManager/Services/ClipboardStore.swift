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

        // 고정된 항목이 항상 최상단에 오도록 정렬
        sortItems()

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
            case .image(_, let fileName, _):
                // 이미지 파일 이름으로 검색
                if let fileName = fileName {
                    return fileName.localizedCaseInsensitiveContains(query)
                }
                return false
            case .url(let url):
                return url.absoluteString.localizedCaseInsensitiveContains(query)
            case .filePath(let url):
                return url.lastPathComponent.localizedCaseInsensitiveContains(query)
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
        case .image(let image, _, let fileURL):
            // 파일 경로가 있으면 파일로 복사 (Finder에 붙여넣기 가능)
            // 없으면 이미지 데이터로 복사 (스크린샷 등)
            if let fileURL = fileURL {
                pasteboard.writeObjects([fileURL as NSURL])
            } else {
                pasteboard.writeObjects([image])
            }
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
            case (.image(_, let newFileName, _), .image(_, let oldFileName, _)):
                // 파일 이름이 있는 경우에만 비교 (스크린샷은 항상 새로 추가)
                if let newName = newFileName, let oldName = oldFileName {
                    return newName == oldName
                }
                return false
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
