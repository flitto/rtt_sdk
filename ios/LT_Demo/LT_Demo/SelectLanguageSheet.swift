import SwiftUI
import LiveTranslationSDK

struct SelectLanguageSheet: View {
  let languageList: [LanguageItemEntity]
  let selectedLanguageAction: (LanguageItemEntity) -> Void

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(languageList) { langItem in
          Button(action: { selectedLanguageAction(langItem) }) {
            Text(langItem.languageLocal)
              .foregroundStyle(.primary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .contentShape(.rect)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
}
