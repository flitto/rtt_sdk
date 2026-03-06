import Foundation
import LiveTranslationSDK
import Observation

@Observable
@MainActor
final class ViewModel {
  init() { }

  private let store = ChatAudienceStore(interactionKey: "820230")
  var isRefreshing: Bool = false

  var chatList: [ChatItemEntity] {
    store.chatList
  }

  var langList: [LanguageItemEntity] {
    store.supportLanguages
  }

  var selectedLangItem: LanguageItemEntity? {
    let selectedCode = store.dstLangCode
    return store.supportLanguages.first(where: { $0.languageCode == selectedCode })
  }

  var chatRoomTitle: String {
    store.roomTitle ?? "Loading..."
  }

  var lastErrorMessage: String? {
    store.lastErrorMessage
  }
}

extension ViewModel {
  public func send(_ inputAction: InputAction) {
    switch inputAction {
    case .onAppearedPage:
      store.connect()
    case .onDisappearedPage:
      store.disconnect()
    case .changeLangCode(let newLang):
      store.requestTranslationLanguage(newLang.languageCode)
    case .refresh:
      refresh()
    }
  }

  private func refresh() {
    guard !isRefreshing else { return }
    isRefreshing = true
    store.disconnect()
    store.connect()
    isRefreshing = false
  }
}

extension ViewModel {
  enum InputAction {
    case onAppearedPage
    case onDisappearedPage
    case changeLangCode(LanguageItemEntity)
    case refresh
  }
}
