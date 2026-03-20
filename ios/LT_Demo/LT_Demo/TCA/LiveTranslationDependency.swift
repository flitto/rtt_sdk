import ComposableArchitecture
import LiveTranslationSDK

// MARK: - LiveTranslationClient

struct LiveTranslationClient: Sendable {
  var connect: @Sendable (String, String?) -> Void
  var disconnect: @Sendable () -> Void
  var requestTranslationLanguage: @Sendable (String) -> Void
  var store: @Sendable () -> ChatAudienceStore
}

// MARK: - Live Value

extension LiveTranslationClient {
  static let live: LiveTranslationClient = {
    let store = ChatAudienceStore()
    return LiveTranslationClient(
      connect: { key, lang in
        store.connect(interactionKey: key, dstLangCode: lang)
      },
      disconnect: {
        store.disconnect()
      },
      requestTranslationLanguage: { lang in
        Task { @MainActor in store.requestTranslationLanguage(lang) }
      },
      store: { store }
    )
  }()
}

// MARK: - State Updates

extension LiveTranslationClient {
  /// A stream that yields the store whenever any observed property changes.
  /// Uses `withObservationTracking` internally — no polling required.
  var stateUpdates: AsyncStream<ChatAudienceStore> {
    let store = self.store()
    return AsyncStream { continuation in
      Task { @MainActor in
        func observe() {
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
            continuation.yield(store)
            Task { @MainActor in observe() }
          }
        }
        observe()
      }
    }
  }
}

// MARK: - DependencyKey

extension LiveTranslationClient: DependencyKey {
  static let liveValue = LiveTranslationClient.live
  static let testValue = LiveTranslationClient(
    connect: { _, _ in },
    disconnect: { },
    requestTranslationLanguage: { _ in },
    store: { ChatAudienceStore() }
  )
}

// MARK: - DependencyValues

extension DependencyValues {
  var liveTranslation: LiveTranslationClient {
    get { self[LiveTranslationClient.self] }
    set { self[LiveTranslationClient.self] = newValue }
  }
}
