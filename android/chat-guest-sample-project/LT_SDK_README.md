# Chat Guest SDK Usage

This document describes how to use `chat-guest` SDK from an Android app.

## 1. Add dependency
```kotlin
dependencies {
    implementation(files("libs/chat-guest-release-260304.aar"))  // // build date (yyMMdd)

    // kotlin serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    // okhttp
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    implementation("com.squareup.okhttp3:okhttp-urlconnection:4.12.0")
    // retrofit
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-kotlinx-serialization:2.11.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}
```

## 2. Public API

Entry point:
- `com.flitto.livetranslation.sdk.chatguest.ChatGuestSdk`

Available functions:
1. `suspend fun connectChat(roomCode: String, initialLangCode: String): String`
- Returns the room name when `roomCode` is valid.
- Throws an exception when fails.

2. `fun observeMessages(): StateFlow<ChatDataEntity>`
- Returns the chat history stream. You may handle UI behavior based on `listType`.
- When an error occurs, you can handle UI behavior based on the model type.

3. `fun requestTranslate(languageCode: String)`
- Requests translation updates using the selected `languageCode`.
- Updated chat items are delivered through `observeMessages()`.

4. `fun disconnectChat()`
- Releases SDK resources and closes the socket connection.

5. `val isConnected: StateFlow<Boolean>`
- Stream of socket connection state (`true` when connected, `false` when disconnected).

6. `val supportLanguages: StateFlow<List<LanguageInfoEntity>>`
- Stream of supported languages.


## 3. Call order

Recommended call sequence:

1. Start observing SocketConnect state, supportLanguages
```kotlin
ChatGuestSdk.isConnected.collect {
    // handle state
}
ChatGuestSdk.supportLanguages.collect {
    // handle supportLanguages
}
```

2. Connect room  
   `val roomName = ChatGuestSdk.connectChat(roomCode = "...", initialLangCode = "...")`
3. Start observing messages  
   `ChatGuestSdk.observeMessages().collect { ... }`
4. Request translation when language changes  
   `ChatGuestSdk.requestTranslate(languageCode = "...")`
5. Close on screen/app end  
   `ChatGuestSdk.disconnectChat()`


### 4. ListType
```
renew - Indicates the initial loaded messages.
append - Indicates the final result for the current utterance.
update - Indicates a corrected/updated message.
realtime - Indicates a real-time partial utterance.
translation - Indicates a translated message.
```


### 5. Model
```kotlin
sealed interface ChatDataEntity {

    // Emitted when the SDK receives an error payload.
    @JvmInline
    value class ErrorEntity(
        val errorCode: Int = -1
    ): ChatDataEntity

    // Emitted for normal chat history updates.
    data class ChatHistoryDataEntity(
        val listType: String = "",
        val chatList: List<ChatHistoryItemEntity> = emptyList()
    ): ChatDataEntity
}

// Single chat item in the merged timeline.
data class ChatHistoryItemEntity(
    val taskType: String = "", // Same as ChatHistoryDataEntity.listType for the same batch.
    val chatRoomId: String = "",
    val chatId: String = "",
    val interactionKey: String = "",
    val timestamp: Long = -1L,
    val text: String = "",
    val textForTr: String = "",
    val srcLanguageCode: String = "",
    val dstLanguageCode: String = "",
    val isRealTime: Boolean = false
)

// Language item from supportLanguages.
data class LanguageInfoEntity(
    val langId: Int = -1,
    val languageCode: String = "", // ko: korean, ja: japan, en: english .. etc
    val languageLocal: String = ""
)
```
