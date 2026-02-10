import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
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
        alert.icon = nil  // 아이콘 제거
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