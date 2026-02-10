# ClipboardManager

<div align="center">
  <h3>🎯 macOS Clipboard Manager</h3>
  <p>Smart clipboard history manager with search, favorites, and floating window</p>

  <p>
    <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="Platform">
    <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift">
    <img src="https://img.shields.io/badge/SwiftUI-3.0+-blue.svg" alt="SwiftUI">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
  </p>
</div>

---

## ✨ Features

- 📋 **Clipboard History**: Automatically track all copied items
- 🔍 **Quick Search**: Find your clipboard history instantly
- ⭐ **Favorites/Pinning**: Pin frequently used items to the top
- 🪟 **Floating Window**: Always-on-top window for easy access
- ⌨️ **Global Hotkey**: Quick toggle with keyboard shortcut (⌘⇧V)
- 🌐 **Multi-language**: Support for Korean, English, and Japanese
- 🎨 **Multiple Types**: Text, Images, Files, and URLs

## 🚀 Getting Started

### Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/devtang-official/ClipboardManager.git
cd ClipboardManager
```

2. Open the project in Xcode:
```bash
open ClipboardManager/ClipboardManager.xcodeproj
```

3. Build and run (⌘R)

### Permissions

The app requires the following permissions:
- **Accessibility**: For global hotkey support
- Grant permission in System Settings > Privacy & Security > Accessibility

## 🏗️ Architecture

```
ClipboardManager/
├── App/                    # App lifecycle & delegates
├── Models/                 # Data models
├── Services/               # Business logic
│   ├── ClipboardMonitor   # NSPasteboard monitoring
│   ├── ClipboardStore     # In-memory storage
│   └── HotkeyManager      # Global hotkey handling
├── ViewModels/            # State management
├── Views/                 # SwiftUI views
│   ├── FloatingWindow    # Main window
│   ├── MenuBarView       # Menu bar integration
│   └── ClipboardHistory  # History list
└── Resources/             # Assets & localizations
    ├── ko.lproj/         # Korean
    ├── en.lproj/         # English
    └── ja.lproj/         # Japanese
```

## 🎯 Usage

### Basic Operations

- **Copy**: Copy any text, image, or file as usual (⌘C)
- **Toggle Window**: Press ⌘⇧V to show/hide the clipboard window
- **Search**: Type in the search bar to filter history
- **Pin Item**: Click the pin icon to keep an item at the top
- **Copy from History**: Click any item to copy it to clipboard
- **Delete**: Right-click and select delete

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘⇧V | Toggle clipboard window |
| ESC | Hide window |
| ⌘F | Focus search bar |
| ↑↓ | Navigate items |
| ⏎ | Copy selected item |

## 🛠️ Development

### Building

```bash
# Build the project
xcodebuild -project ClipboardManager.xcodeproj -scheme ClipboardManager build

# Run tests
xcodebuild test -project ClipboardManager.xcodeproj -scheme ClipboardManager
```

### Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global hotkey management

## 🗺️ Roadmap

- [ ] Core functionality
  - [x] Clipboard monitoring
  - [x] History storage (in-memory)
  - [ ] Search & filtering
  - [ ] Pin/favorite items
  - [ ] Multiple clipboard types
- [ ] UI/UX
  - [ ] Floating window
  - [ ] Menu bar integration
  - [ ] Dark mode support
- [ ] Features
  - [ ] Global hotkey
  - [ ] Multi-language support
  - [ ] Export/import history
  - [ ] Sync with iCloud

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**DevTang**
- GitHub: [@devtang-official](https://github.com/devtang-official)

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Inspired by clipboard managers like Paste, Copied, and others

---

<div align="center">
  Made with ❤️ by DevTang
</div>
