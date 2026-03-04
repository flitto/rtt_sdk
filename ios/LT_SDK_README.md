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
init(interactionKey: String, dstLangCode: String? = nil)
```

Available functions:

```swift
func connect()
func disconnect()
func requestTranslationLanguage(_ langCode: String)
```

Available properties:

```swift
var isConnected: Bool
var chatList: [ChatItemEntity]
var supportLanguages: [LanguageItemEntity]
var dstLangCode: String?
var roomTitle: String?
var lastErrorMessage: String?
```

## 3. Call order
Recommended call sequence:

1. Create store
```swift
@MainActor
let store = ChatAudienceStore(
  interactionKey: "...",
  dstLangCode: "ja"
)
```

2. Connect when entering the screen
```swift
store.connect()
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

## 4. ListType (`ChatItemEntity.taskType`)
`ChatItemEntity.taskType` can contain:

- `renew` - Initial loaded messages
- `append` - Final result for the current utterance
- `update` - Corrected/updated message
- `realtime` - Partial real-time utterance
- `translation` - Translated message

You can also use `isRealTime == true` to handle real-time UI behavior.

## 5. Model
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
