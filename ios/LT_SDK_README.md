# Chat Audience SDK Usage (iOS)

This document explains how to use `LiveTranslationSDK` in iOS/macOS/visionOS apps.

## 1. Add dependency
In this repository, the demo uses a local binary framework (no remote SPM dependency).

- SDK binary path: `ios/binary/LiveTranslationSDK.xcframework`
- Demo project: `ios/LT_Demo/LT_Demo.xcodeproj`

To integrate into a regular Xcode app:
1. Add `LiveTranslationSDK.xcframework` to your project.
2. Register it in Target > General > `Frameworks, Libraries, and Embedded Content`.
3. Use `Embed & Sign` for the embed option.

## 2. Public API
Entry point:

`LiveTranslationSDK.ChatAudienceStore`

Available initializer:

```swift
init()
```

Available functions:

```swift
func connect(interactionKey: String, dstLangCode: String? = nil)
func disconnect()
@MainActor func requestTranslationLanguage(_ langCode: String)
```

Available properties:

```swift
@MainActor var isConnected: Bool
@MainActor var chatList: [ChatItemEntity]
@MainActor var supportLanguages: [LanguageItemEntity]
@MainActor var dstLangCode: String?
@MainActor var roomTitle: String?
@MainActor var lastErrorMessage: String?
```

### Actor isolation

`connect()` and `disconnect()` are not actor-isolated and can be called from any concurrency context without `await` or `MainActor.run`.

```swift
// Callable from anywhere — no await needed
store.connect(interactionKey: "your-key", dstLangCode: "ja")
store.disconnect()
```

State properties (`chatList`, `isConnected`, etc.) are `@MainActor`-isolated, so they are safe to read directly from SwiftUI views or any `@MainActor` context.

## 3. Call order
Recommended call sequence:

1. Create store
```swift
let store = ChatAudienceStore()
```

2. Connect when entering the screen
```swift
store.connect(interactionKey: "...", dstLangCode: "ja")
```

3. Reflect message/language/error states
- `store.chatList`
- `store.supportLanguages`
- `store.lastErrorMessage`

4. Request translation when language changes
```swift
store.requestTranslationLanguage("en")
```

5. Disconnect when leaving the screen
```swift
store.disconnect()
```

## 4. Observation

`ChatAudienceStore` conforms to `@Observable`, so no polling or manual callbacks are needed.

### SwiftUI

Properties are tracked automatically. The view re-renders whenever any observed property changes.

```swift
struct ChatView: View {
    let store: ChatAudienceStore

    var body: some View {
        List(store.chatList) { item in
            Text(item.textForTr)
        }
    }
}
```

### TCA / AsyncStream

Use `withObservationTracking` to bridge into an `AsyncStream`:

```swift
let stream = AsyncStream<ChatAudienceStore> { continuation in
    var observationTask: Task<Void, Never>?

    func observe() {
        observationTask = Task { @MainActor in
            guard !Task.isCancelled else { return }

            withObservationTracking {
                MainActor.assumeIsolated {
                    _ = store.isConnected
                    _ = store.chatList
                    _ = store.supportLanguages
                    _ = store.dstLangCode
                    _ = store.roomTitle
                    _ = store.lastErrorMessage
                }
            } onChange: {
                guard !Task.isCancelled else { return }
                continuation.yield(store)
                observe()
            }
        }
    }

    // Yield the current snapshot immediately so consumers receive initial state.
    continuation.yield(store)

    // Then observe future changes.
    observe()

    continuation.onTermination = { _ in
        observationTask?.cancel()
    }
}
```

This fires only on actual property changes — no polling, no latency.

A complete TCA integration example (`LiveTranslationClient`, `LiveTranslationFeature` reducer, `StoreSnapshot`) is available in the demo app under `ios/LT_Demo/LT_Demo/TCA/`.

## 5. ListType (`ChatItemEntity.taskType`)
`ChatItemEntity.taskType` can contain:

- `renew` - Initial loaded messages
- `append` - Final result for the current utterance
- `update` - Corrected/updated message
- `realtime` - Partial real-time utterance
- `translation` - Translated message

You can also use `isRealTime == true` to handle real-time UI behavior.

## 6. Model
```swift
public struct ChatItemEntity: Equatable, Identifiable, Sendable {
  public let taskType: String
  public let chatRoomId: String
  public let chatId: String
  public let interactionKey: String
  public let timestamp: Int
  public let text: String
  public let textForTr: String
  public let srcLanguageCode: String
  public let dstLanguageCode: String
  public var id: String { get }
  public var isRealTime: Bool { get }
}

public struct LanguageItemEntity: Equatable, Identifiable, Sendable {
  public let langId: Int
  public let languageCode: String      // ko, ja, en ...
  public let languageLocal: String
  public var id: Int { get }
}
```
