import LiveTranslationSDK
import SwiftUI

struct ChatRowView: View {
  let item: ChatItemEntity

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      if item.isRealTime {
        ChatRealtimeDotsView()
          .padding(.top, 5)
      }
      Text(item.textForTr.isEmpty ? item.text : item.textForTr)
        .font(.system(size: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .foregroundStyle(.primary)
    }
  }
}

struct ChatRealtimeDotsView: View {
  @State private var phase = 0

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<3, id: \.self) { index in
        Circle()
          .fill(Color.secondary.opacity(0.4))
          .frame(width: 8, height: 8)
          .opacity(phase == index ? 1.0 : 0.35)
      }
    }
    .task {
      while !Task.isCancelled {
        try? await Task.sleep(nanoseconds: 320_000_000)
        phase = (phase + 1) % 3
      }
    }
    .accessibilityHidden(true)
  }
}
