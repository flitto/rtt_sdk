import ComposableArchitecture
import LiveTranslationSDK

// MARK: - StoreSnapshot

/// A value-type snapshot of `ChatAudienceStore`'s @MainActor properties.
/// Since the Reducer is nonisolated, this type is passed as an Action instead of a Store reference.
struct StoreSnapshot: Equatable, Sendable {
  let isConnected: Bool
  let chatList: [ChatItemEntity]
  let supportLanguages: [LanguageItemEntity]
  let dstLangCode: String?
  let roomTitle: String?
  let lastErrorMessage: String?

  @MainActor
  init(from store: ChatAudienceStore) {
    isConnected = store.isConnected
    chatList = store.chatList
    supportLanguages = store.supportLanguages
    dstLangCode = store.dstLangCode
    roomTitle = store.roomTitle
    lastErrorMessage = store.lastErrorMessage
  }
}

// MARK: - Reducer

@Reducer
struct LiveTranslationFeature {

  // MARK: - State

  @ObservableState
  struct State: Equatable, Sendable {
    var isConnected: Bool = false
    var chatList: [ChatItemEntity] = []
    var supportLanguages: [LanguageItemEntity] = []
    var dstLangCode: String?
    var roomTitle: String?
    var lastErrorMessage: String?
    var isLanguageSheetPresented: Bool = false

    var selectedLanguage: LanguageItemEntity? {
      guard let code = dstLangCode else { return nil }
      return supportLanguages.first { $0.languageCode == code }
    }
  }

  // MARK: - Action

  enum Action {
    case onAppear
    case onDisappear
    case refresh
    case languageButtonTapped
    case languageSheetDismissed
    case languageSelected(LanguageItemEntity)
    case storeUpdated(StoreSnapshot)
  }

  // MARK: - Dependencies

  @Dependency(\.liveTranslation) var client

  private enum CancelID { case observation }

  // MARK: - Reducer

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {

      case .onAppear:
        client.connect("820230", state.dstLangCode)
        return .run { send in
          for await store in client.stateUpdates {
            let snapshot = await MainActor.run { StoreSnapshot(from: store) }
            await send(.storeUpdated(snapshot))
          }
        }
        .cancellable(id: CancelID.observation)

      case .onDisappear:
        client.disconnect()
        return .cancel(id: CancelID.observation)

      case .refresh:
        let currentLangCode = state.dstLangCode
        client.disconnect()
        client.connect("820230", currentLangCode)
        return .none

      case .languageButtonTapped:
        state.isLanguageSheetPresented = true
        return .none

      case .languageSheetDismissed:
        state.isLanguageSheetPresented = false
        return .none

      case .languageSelected(let item):
        state.isLanguageSheetPresented = false
        client.requestTranslationLanguage(item.languageCode)
        return .none

      case .storeUpdated(let snapshot):
        state.isConnected = snapshot.isConnected
        state.chatList = snapshot.chatList
        state.supportLanguages = snapshot.supportLanguages
        state.dstLangCode = snapshot.dstLangCode
        state.roomTitle = snapshot.roomTitle
        state.lastErrorMessage = snapshot.lastErrorMessage
        return .none
      }
    }
  }
}
