import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let onCopy: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 타입 아이콘
            Image(systemName: typeIcon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 30)

            // 콘텐츠 미리보기
            VStack(alignment: .leading, spacing: 4) {
                Text(previewText)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text(timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // 액션 버튼
            HStack(spacing: 4) {
                Button(action: onPin) {
                    Image(systemName: item.isPinned ? "pin.slash" : "pin")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help(item.isPinned ? "action.unpin" : "action.pin")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("action.delete")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
    }

    private var typeIcon: String {
        switch item.type {
        case .text:
            return "doc.text"
        case .image:
            return "photo"
        case .filePath:
            return "doc"
        case .url:
            return "link"
        }
    }

    private var previewText: String {
        switch item.content {
        case .text(let text):
            return text
        case .image:
            return "🖼️ Image"
        case .filePath(let url):
            return url.lastPathComponent
        case .url(let url):
            return url.absoluteString
        }
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(item.timestamp)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 {
            return NSLocalizedString("time.just_now", comment: "")
        } else if minutes < 60 {
            return String(format: NSLocalizedString("time.minutes_ago", comment: ""), minutes)
        } else if hours < 24 {
            return String(format: NSLocalizedString("time.hours_ago", comment: ""), hours)
        } else {
            return String(format: NSLocalizedString("time.days_ago", comment: ""), days)
        }
    }
}

#Preview {
    VStack {
        ClipboardItemRow(
            item: ClipboardItem(content: .text("Hello, World!")),
            onCopy: {},
            onPin: {},
            onDelete: {}
        )

        ClipboardItemRow(
            item: ClipboardItem(content: .url(URL(string: "https://github.com")!), isPinned: true),
            onCopy: {},
            onPin: {},
            onDelete: {}
        )
    }
    .padding()
}