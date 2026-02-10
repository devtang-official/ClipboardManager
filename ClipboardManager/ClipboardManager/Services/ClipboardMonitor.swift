import Foundation
import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int
    private var shouldIgnoreNextChange: Bool = false

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

    // 다음 클립보드 변경을 무시하도록 설정
    func ignoreNextChange() {
        shouldIgnoreNextChange = true
    }

    // 클립보드 변경 확인
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        // changeCount가 변경되었으면 새로운 복사가 발생한 것
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // 다음 변경 무시 플래그가 설정되어 있으면 무시
        if shouldIgnoreNextChange {
            shouldIgnoreNextChange = false
            return
        }

        // 클립보드에서 데이터 추출
        if let item = extractClipboardItem(from: pasteboard) {
            onNewItem?(item)
        }
    }

    // 클립보드에서 데이터 추출 (우선순위: 파일 > URL > 이미지 > 텍스트)
    private func extractClipboardItem(from pasteboard: NSPasteboard) -> ClipboardItem? {
        // 1. 파일 URL 확인 (Finder에서 복사한 파일)
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           let fileURL = urls.first,
           fileURL.isFileURL {
            // 이미지 파일 확장자 체크
            let imageExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "heic", "heif", "webp"]
            let fileExtension = fileURL.pathExtension.lowercased()

            if imageExtensions.contains(fileExtension) {
                // 이미지 파일이면 이미지로 로드
                if let image = NSImage(contentsOf: fileURL) {
                    return ClipboardItem(content: .image(image))
                }
            }

            // 일반 파일
            return ClipboardItem(content: .filePath(fileURL))
        }

        // 2. URL 확인 (http, https 등)
        if let string = pasteboard.string(forType: .string),
           let url = URL(string: string),
           url.scheme != nil,
           (url.scheme == "http" || url.scheme == "https" || url.scheme == "ftp") {
            return ClipboardItem(content: .url(url))
        }

        // 3. 이미지 데이터 확인 (스크린샷, 이미지 앱에서 복사 등)
        if let image = NSImage(pasteboard: pasteboard) {
            return ClipboardItem(content: .image(image))
        }

        // 4. 텍스트 확인
        if let string = pasteboard.string(forType: .string) {
            return ClipboardItem(content: .text(string))
        }

        return nil
    }
}
