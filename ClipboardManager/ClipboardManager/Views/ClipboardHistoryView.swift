import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        if viewModel.isCompactMode {
            compactModeView
        } else {
            normalModeView
        }
    }

    // 일반 모드 뷰
    private var normalModeView: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                // 토글 버튼 추가 (왼쪽)
                Button(action: {
                    viewModel.toggleCompactMode()
                }) {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle Compact Mode")

                Text("history.title")
                    .font(.headline)

                Spacer()

                // 모두 삭제 버튼 (기존)
                if !displayedItems.isEmpty {
                    Button(action: {
                        clearAllItems()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("history.clear_all")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("history.clear_all")
                }

                Text(String(format: NSLocalizedString("history.item_count", comment: ""), displayedItems.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()

            // 검색바
            SearchBar(text: $viewModel.searchQuery)
                .padding(.horizontal)
                .padding(.bottom, 12)

            Divider()

            // 히스토리 목록
            if displayedItems.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(displayedItems) { item in
                            ClipboardItemRow(
                                item: item,
                                onCopy: {
                                    viewModel.copyToClipboard(item: item)
                                },
                                onPin: {
                                    viewModel.togglePin(id: item.id)
                                },
                                onDelete: {
                                    viewModel.deleteItem(id: item.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // Compact 모드 뷰 (2줄 구조)
    private var compactModeView: some View {
        VStack(spacing: 4) {
            // 첫 줄: 토글 + 검색바 + 카운트
            HStack(spacing: 8) {
                // 토글 버튼
                Button(action: {
                    viewModel.toggleCompactMode()
                }) {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle Normal Mode")

                // 검색바 (인라인)
                SearchBar(text: $viewModel.searchQuery)

                // 아이템 카운트
                if !displayedItems.isEmpty {
                    Text(String(format: NSLocalizedString("history.item_count", comment: ""), displayedItems.count))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            // 두 번째 줄: 첫 번째 아이템 표시
            if let firstItem = displayedItems.first {
                ClipboardItemRow(
                    item: firstItem,
                    onCopy: {
                        viewModel.copyToClipboard(item: firstItem)
                    },
                    onPin: {
                        viewModel.togglePin(id: firstItem.id)
                    },
                    onDelete: {
                        viewModel.deleteItem(id: firstItem.id)
                    }
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            } else {
                Text("history.empty")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }

    private var displayedItems: [ClipboardItem] {
        viewModel.searchQuery.isEmpty ? viewModel.items : viewModel.filteredItems
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("history.empty")
                .font(.headline)

            Text("history.empty.description")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func clearAllItems() {
        // 확인 알림 표시
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("history.clear_all", comment: "")
        alert.informativeText = NSLocalizedString("history.clear_all.confirm", comment: "")
        alert.alertStyle = .warning
        alert.icon = NSApp.applicationIconImage  // 앱 아이콘 사용
        alert.addButton(withTitle: NSLocalizedString("action.confirm", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("action.cancel", comment: ""))

        if alert.runModal() == .alertFirstButtonReturn {
            // 모든 항목 삭제
            for item in viewModel.items {
                viewModel.deleteItem(id: item.id)
            }
        }
    }
}

#Preview {
    ClipboardHistoryView(viewModel: ClipboardViewModel())
        .frame(width: 400, height: 600)
}