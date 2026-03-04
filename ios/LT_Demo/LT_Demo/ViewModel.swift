import Foundation
import LiveTranslationSDK
import Observation

@Observable
@MainActor
final class ViewModel {
  init() { }

  var chatList: [ChatItemEntity] = []
  var langList: [LanguageItemEntity] = []
  var selectedLangItem: LanguageItemEntity?
  var chatRoomTitle: String = "Loading..."
  var isRefreshing: Bool = false

  private let audience = ChatAudience(interactionKey: "689101", dstLangCode: "en")
  private var chatStreamTask: Task<Void, Never>?
}

extension ViewModel {
  public func send(_ inputAction: InputAction) {
    switch inputAction {
    case .onAppearedPage:
      Task { await loadLangList() }
    case .connectChatStream:
      startChatStream()
    case .changeLangCode(let newLang):
      selectedLangItem = newLang
      Task { await audience.requestTranslationLanguage(newLang.languageCode) }
    case .refresh:
      Task { await refresh() }
    }
  }

  private func startChatStream() {
    chatStreamTask?.cancel()
    chatStreamTask = Task { await connectChat() }
  }
}

extension ViewModel {

  private func loadLangList() async {
    do {
      langList = try await audience.getSupportLanguages()
      if selectedLangItem == nil {
        selectedLangItem = langList.first(where: { $0.languageCode == "en" }) ?? langList.first
      }
      #if DEBUG
      print("[LT_Demo] language list loaded count=\(langList.count)")
      #endif
    } catch {
      #if DEBUG
      print("[LT_Demo][ERROR] loadLangList error: \(error)")
      #endif
    }
  }

  private func loadChatRoomTitle() async {
    do {
      let info = try await audience.getChatRoomInfo()
      chatRoomTitle = info.chatRoomTitle
      #if DEBUG
      print("[LT_Demo] chat room title loaded: \(chatRoomTitle)")
      #endif
    } catch {
      #if DEBUG
      print("[LT_Demo][ERROR] loadChatRoomTitle error: \(error)")
      #endif
    }
  }

  private func refresh() async {
    guard !isRefreshing else { return }
    isRefreshing = true
    defer { isRefreshing = false }

    await audience.disconnectChat()
    chatList = []
    await loadChatRoomTitle()
    startChatStream()
  }

  private func connectChat() async {
    #if DEBUG
    print("[LT_Demo] connectChat start")
    #endif
    await loadChatRoomTitle()
    do {
      for try await chatList in await audience.connectChat() {
        self.chatList = chatList
        #if DEBUG
        print("[LT_Demo] chat update count=\(chatList.count)")
        #endif
      }
      #if DEBUG
      print("[LT_Demo][WARN] connectChat stream finished")
      #endif
    } catch {
      #if DEBUG
      print("[LT_Demo][ERROR] connectChat error: \(error)")
      #endif
    }
  }
}

extension ViewModel {
  enum InputAction {
    case onAppearedPage
    case connectChatStream
    case changeLangCode(LanguageItemEntity)
    case refresh
  }
}
