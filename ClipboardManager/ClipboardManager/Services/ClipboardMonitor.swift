import Foundation
import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int

    // 새로운 클립보드 항목이 감지되었을 때 호출되는 클로저
    var onNewItem: ((ClipboardItem) -> Void)?

    init() {
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    // 모니터링 시작
    func startMonitoring() {
        // 앱 시작 시 현재 클립보드 내용 읽기
        checkClipboard()

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    // 모니터링 중지
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // 현재 changeCount를 업데이트하여 다음 체크를 건너뛰도록
    func updateChangeCount() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    // 클립보드 변경 확인
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        // changeCount가 변경되었으면 새로운 복사가 발생한 것
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // 클립보드에서 데이터 추출
        if let item = extractClipboardItem(from: pasteboard) {
            onNewItem?(item)
        }
    }

    // 클립보드에서 데이터 추출 (우선순위: 이미지 > URL > 파일 > 텍스트)
    private func extractClipboardItem(from pasteboard: NSPasteboard) -> ClipboardItem? {
        // 1. 이미지 확인
        if let image = NSImage(pasteboard: pasteboard) {
            return ClipboardItem(content: .image(image))
        }

        // 2. 파일 URL 확인
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           let fileURL = urls.first,
           fileURL.isFileURL {
            return ClipboardItem(content: .filePath(fileURL))
        }

        // 3. URL 확인
        if let string = pasteboard.string(forType: .string),
           let url = URL(string: string),
           url.scheme != nil {
            return ClipboardItem(content: .url(url))
        }

        // 4. 텍스트 확인
        if let string = pasteboard.string(forType: .string) {
            return ClipboardItem(content: .text(string))
        }

        return nil
    }
}
