import Foundation
import LiveTranslationSDK_iOS

@Observable
@MainActor
class ViewModel {
  init() { }

  var chatList: [ChatItemEntity] = []
  var langList: [LanguageItemEntity] = []
  var selectedLangItem: LanguageItemEntity?

  private let audience = ChatAudience(interactionKey: "490294", dstLangCode: "en")
}

extension ViewModel {
  public func send(_ inputAction: InputAction) {
    switch inputAction {
    case .onAppearedPage:
      Task { await loadLangList() }
    case .connectChatStream:
      Task { await connectChat() }
    case .changeLangCode(let newLang):
      selectedLangItem = newLang
      Task { await audience.changeDstLanguage(newLang.languageCode) }
    }
  }
}

extension ViewModel {

  private func loadLangList() async {
    do {
      langList = try await audience.getSupportLanguages()
    } catch {
      print(error.localizedDescription)
    }
  }

  private func connectChat() async {
    do {
      for try await chatList in await audience.connect() {
        self.chatList = chatList
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}

extension ViewModel {
  enum InputAction {
    case onAppearedPage
    case connectChatStream
    case changeLangCode(LanguageItemEntity)
  }
}
