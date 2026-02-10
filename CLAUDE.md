# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Work Guidelines (작업 규칙)

**Claude는 반드시 다음 규칙을 따라야 합니다:**

1. **물어보고 작업하기**
   - 모든 코드 작성, 파일 생성, 구조 변경 전에 사용자에게 확인을 받을 것
   - 여러 옵션이 있는 경우 사용자에게 선택권을 제공할 것
   - 불확실한 사항은 가정하지 말고 반드시 질문할 것

2. **설계가 변경되면 즉시 CLAUDE.md에 반영하기**
   - 아키텍처, 구조, 패턴이 변경되면 이 문서를 즉시 업데이트할 것
   - Dependencies, Core Components 섹션을 항상 최신 상태로 유지할 것

3. **답변은 무조건 한국어로만**
   - 모든 설명, 주석, 커뮤니케이션은 한국어로 작성할 것
   - 코드 내 변수명, 함수명 등은 영어 사용 (Swift 컨벤션 준수)

4. **모르는 것이 있으면 무작정 해결하지 말고 질문하기**
   - 확신이 없는 기술적 결정은 사용자에게 문의할 것
   - 에러나 문제 발생 시 임의로 우회하지 말고 사용자와 상의할 것
   - 추측으로 코드를 작성하지 말 것

## Project Overview

ClipboardManager는 macOS용 클립보드 관리 애플리케이션입니다.

## Development Commands

### Xcode 프로젝트 설정 후
```bash
# 프로젝트 빌드
xcodebuild -project ClipboardManager.xcodeproj -scheme ClipboardManager build

# 테스트 실행
xcodebuild test -project ClipboardManager.xcodeproj -scheme ClipboardManager

# 앱 실행 (Xcode에서)
# Product > Run (⌘R) 사용
```

### Swift Package Manager 사용 시
```bash
# 빌드
swift build

# 테스트
swift test

# 실행
swift run
```

## Architecture

### Core Components (프로젝트 진행에 따라 업데이트)

**클립보드 모니터링**
- macOS의 `NSPasteboard` API를 사용하여 클립보드 변경사항 감지
- Polling 또는 `NSPasteboard.changeCount` 모니터링

**데이터 저장**
- 클립보드 히스토리 저장 방식 (Core Data, SQLite, 또는 파일 시스템)
- 텍스트, 이미지, 파일 등 다양한 타입 지원

**UI 컴포넌트**
- 메뉴바 아이콘 (NSStatusItem)
- 히스토리 팝오버 또는 윈도우
- 글로벌 단축키 지원

**다국어 지원 (Localization)**
- 지원 언어: 한국어(ko), 영어(en), 일본어(ja)
- Localizable.strings를 통한 문자열 리소스 관리
- 각 언어별 .lproj 폴더 구조 (ko.lproj, en.lproj, ja.lproj)
- 시스템 언어 설정에 따른 자동 전환

### macOS 특정 고려사항

**권한**
- 접근성 권한 (Accessibility): 글로벌 단축키 및 다른 앱의 클립보드 접근
- 백그라운드 실행 설정

**샌드박스**
- App Sandbox 사용 시 적절한 entitlements 설정 필요
- 파일 접근, 네트워크, 사용자 선택 파일 등의 권한

**메뉴바 앱 패턴**
- `LSUIElement` = YES (Info.plist에서 Dock 아이콘 숨김)
- NSStatusItem을 사용한 메뉴바 통합

## Code Patterns

### 클립보드 모니터링 예시 패턴
```swift
class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
}
```

### 글로벌 단축키 등록
- Carbon 기반 또는 서드파티 라이브러리 (예: MASShortcut, KeyboardShortcuts)
- 접근성 권한 확인 필요

### 다국어 문자열 사용 패턴
```swift
// SwiftUI에서 LocalizedStringKey 사용
Text("app.title")  // Localizable.strings에서 자동으로 로드

// 코드에서 문자열 가져오기
let localizedString = NSLocalizedString("clipboard.empty", comment: "빈 클립보드 메시지")

// String interpolation
Text("clipboard.count \(count)")
```

**Localizable.strings 구조 예시:**
```
// ko.lproj/Localizable.strings
"app.title" = "클립보드 매니저";
"search.placeholder" = "검색...";
"clipboard.empty" = "클립보드가 비어있습니다";
```

## Testing Strategy

- 단위 테스트: 비즈니스 로직 및 데이터 모델
- UI 테스트: 메인 윈도우 및 상호작용 (XCTest)
- 수동 테스트: 다양한 클립보드 타입 (텍스트, 이미지, 파일 등)

## Dependencies

프로젝트에 추가되는 의존성은 여기에 문서화하세요:
- Swift Package Manager를 통한 패키지
- CocoaPods (사용 시)
- 직접 포함된 라이브러리
