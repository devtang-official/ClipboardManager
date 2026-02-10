import Foundation
import Combine

class ClipboardViewModel: ObservableObject {
    // Published 속성
    @Published var items: [ClipboardItem] = []
    @Published var searchQuery: String = ""
    @Published var filteredItems: [ClipboardItem] = []

    // 서비스
    private let monitor: ClipboardMonitor
    private let store: ClipboardStore

    private var cancellables = Set<AnyCancellable>()

    init(monitor: ClipboardMonitor = ClipboardMonitor(),
         store: ClipboardStore = ClipboardStore()) {
        self.monitor = monitor
        self.store = store

        setupBindings()
        setupMonitoring()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Store의 items 변경을 구독
        store.$items
            .assign(to: &$items)

        // searchQuery 변경 시 filteredItems 업데이트
        Publishers.CombineLatest($items, $searchQuery)
            .map { [weak self] items, query in
                guard let self = self else { return [] }
                if query.isEmpty {
                    return items
                }
                return self.store.search(query: query)
            }
            .assign(to: &$filteredItems)
    }

    private func setupMonitoring() {
        monitor.onNewItem = { [weak self] item in
            self?.store.add(item: item)
        }
        monitor.startMonitoring()
    }

    // MARK: - Public Methods

    func togglePin(id: UUID) {
        store.togglePin(id: id)
    }

    func deleteItem(id: UUID) {
        store.remove(id: id)
    }

    func copyToClipboard(item: ClipboardItem) {
        // 다음 클립보드 변경 무시 플래그 설정
        monitor.ignoreNextChange()

        // 클립보드에 복사
        store.copyToClipboard(item: item)
    }

    func clearSearch() {
        searchQuery = ""
    }

    // MARK: - Lifecycle

    deinit {
        monitor.stopMonitoring()
    }
}