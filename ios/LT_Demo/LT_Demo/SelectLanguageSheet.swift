import SwiftUI
import LiveTranslationSDK_iOS

struct SelectLanguageSheet: View {
  let languageList: [LanguageEntity.Response.LanguageItem]
  let selectedLanguageAction: (LanguageEntity.Response.LanguageItem) -> Void

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(languageList, id: \.id) { langItem in
          Button(action: { selectedLanguageAction(langItem) }) {
            Text(langItem.langORG)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .contentShape(.rect)
          }
        }
      }
    }
  }
}
