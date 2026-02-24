import LiveTranslationSDK_iOS
import SwiftUI

@main
struct LT_DemoApp: App {
  init() {
    LiveTranslationSDK.configure(environment: .development)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
