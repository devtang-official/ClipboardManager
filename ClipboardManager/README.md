# ClipboardManager - Memento

<p align="center">
  <img src="ClipboardManager/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" width="128" height="128" alt="Memento Icon">
</p>

<p align="center">
  <strong>잊혀지는 기억을 소중히 간직하겠습니다.</strong>
</p>

## 소개

Memento는 macOS용 스마트 클립보드 히스토리 관리 앱입니다. 복사한 모든 내용을 기억하고, 필요할 때 빠르게 찾아볼 수 있습니다.

## 주요 기능

- 📋 **클립보드 히스토리 관리** - 텍스트, 이미지, 파일, URL 지원
- 🔍 **빠른 검색** - 실시간 검색으로 원하는 항목을 즉시 찾기
- 📌 **핀 고정** - 자주 사용하는 항목을 상단에 고정
- ⌨️ **글로벌 단축키** - Command + Shift + V로 어디서든 빠르게 접근
- 🎨 **컴팩트 모드** - 최소한의 공간으로 최대한의 효율
- 🌍 **다국어 지원** - 한국어, 영어, 일본어

## 시스템 요구사항

- macOS 12.0 (Monterey) 이상
- Apple Silicon 또는 Intel 프로세서

## 설치

```bash
# 프로젝트 클론
git clone https://github.com/devtang-official/ClipboardManager.git
cd ClipboardManager/ClipboardManager

# Xcode로 빌드
xcodebuild -project ClipboardManager.xcodeproj -scheme ClipboardManager build
```

## 사용법

1. **앱 실행** - Dock 또는 Applications 폴더에서 Memento 실행
2. **단축키** - `⌘⇧V`를 눌러 클립보드 윈도우 열기/닫기
3. **검색** - 검색창에 키워드 입력으로 히스토리 필터링
4. **복사** - 항목 클릭으로 클립보드에 다시 복사
5. **고정** - 📌 버튼으로 자주 사용하는 항목 고정

## 기술 스택

- **SwiftUI** - 모던한 UI 프레임워크
- **AppKit** - macOS 네이티브 통합 (메뉴바, 플로팅 윈도우)
- **Combine** - 반응형 프로그래밍
- **Carbon API** - 글로벌 단축키

## 라이선스

MIT License

## 개발자

Made with ❤️ by devtang

---

**Memento** - 모든 순간을 기억합니다.
