import SwiftUI

struct ContentView: View {
  let viewModel = ViewModel()
  @State var isSelectedLanguageSheet: Bool = false

  var body: some View {
    VStack {
      ScrollView {
        LazyVStack {
          ForEach(viewModel.chatList) { item in
            Text(item.textForTr.isEmpty ? item.text : item.textForTr)
              .frame(maxWidth: .infinity, alignment: .leading)
              .multilineTextAlignment(.leading)
              .padding()
          }
        }
      }

      Button(action: { isSelectedLanguageSheet.toggle() }) {
        Text("Select language (Current language is \(viewModel.selectedLangItem?.languageLocal ?? ""))")
      }
    }
    .task {
      viewModel.send(.onAppearedPage)
      viewModel.send(.connectChatStream)
    }
    .sheet(isPresented: $isSelectedLanguageSheet) {
      SelectLanguageSheet(
        languageList: viewModel.langList,
        selectedLanguageAction: { langCode in
          viewModel.send(.changeLangCode(langCode))
          isSelectedLanguageSheet = false
        })
    }
  }
}
