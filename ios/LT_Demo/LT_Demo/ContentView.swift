import SwiftUI

struct ContentView: View {
  @State private var viewModel = ViewModel()
  @State private var isSelectedLanguageSheet: Bool = false
  @State private var isNearBottom: Bool = true

  private let bottomAnchorID = "chat-bottom-anchor"

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollViewReader { scrollProxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 28) {
            ForEach(viewModel.chatList) { item in
              HStack(alignment: .top, spacing: 10) {
                if item.isRealTime {
                  RealtimeDotsView()
                    .padding(.top, 5)
                }

                Text(item.textForTr.isEmpty ? item.text : item.textForTr)
                  .font(.system(size: 16))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .multilineTextAlignment(.leading)
                  .foregroundStyle(.primary)
              }
            }

            Color.clear
              .frame(height: 30)
              .id(bottomAnchorID)
              .overlay {
                Color.clear
                  .frame(height: 1)
                  .offset(y: -100)
                  .onAppear { isNearBottom = true }
                  .onDisappear { isNearBottom = false }
              }
          }
          .padding(.horizontal, 24)
          .padding(.top, 28)
          .padding(.bottom, 48)
        }
        .onChange(of: viewModel.chatList.last?.id) { oldValue, newValue in
          guard newValue != nil else { return }
          guard isNearBottom || oldValue == nil else { return }
          scrollToBottom(using: scrollProxy, animated: oldValue != nil)
        }
      }
      .background(Color(.systemGray6))
    }
    .background(Color(.systemGray6))
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

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(spacing: 12) {
        Text(viewModel.chatRoomTitle)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.primary)
          .lineLimit(1)

        Spacer(minLength: 0)

        Button(action: { viewModel.send(.refresh) }) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(.primary)
            .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isRefreshing)
      }

      Button(action: { isSelectedLanguageSheet = true }) {
        HStack(spacing: 10) {
          Image(systemName: "globe")
            .font(.system(size: 14))
          Text(viewModel.selectedLangItem?.languageLocal ?? "Language")
            .font(.system(size: 14, weight: .regular))
          Image(systemName: "chevron.down")
            .font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .overlay(
          Capsule()
            .stroke(Color(.systemGray4), lineWidth: 2)
        )
        .clipShape(Capsule())
      }
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
    .padding(.top, 24)
    .padding(.bottom, 28)
    .background(Color(.systemBackground))
    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
  }

  private func scrollToBottom(using proxy: ScrollViewProxy, animated: Bool) {
    if animated {
      withAnimation(.easeOut(duration: 0.2)) {
        proxy.scrollTo(bottomAnchorID, anchor: .bottom)
      }
    } else {
      proxy.scrollTo(bottomAnchorID, anchor: .bottom)
    }
  }
}

private struct RealtimeDotsView: View {
  @State private var phase = 0
  private let timer = Timer.publish(every: 0.32, on: .main, in: .common).autoconnect()

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<3, id: \.self) { index in
        Circle()
          .fill(Color(.systemGray3))
          .frame(width: 8, height: 8)
          .opacity(phase == index ? 1.0 : 0.35)
      }
    }
    .onReceive(timer) { _ in
      phase = (phase + 1) % 3
    }
    .accessibilityHidden(true)
  }
}
