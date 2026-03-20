import ComposableArchitecture
import SwiftUI
import LiveTranslationSDK

@main
struct LT_DemoApp: App {

  var body: some Scene {
    WindowGroup {
      TabView {
        Tab("ViewModel", systemImage: "person.circle") {
          ContentView()
        }
        Tab("TCA", systemImage: "arrow.trianglehead.2.clockwise") {
          LiveTranslationTCAView(
            store: Store(initialState: LiveTranslationFeature.State()) {
              LiveTranslationFeature()
            }
          )
        }
      }
      .onAppear {
        LiveTranslationSDKConfiguration.configure(environment: .development)
      }
    }
  }
}
