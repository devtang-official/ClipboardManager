import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("history.title")
                    .font(.headline)

                Spacer()

                Text("history.item_count")
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
}

#Preview {
    ClipboardHistoryView(viewModel: ClipboardViewModel())
        .frame(width: 400, height: 600)
}