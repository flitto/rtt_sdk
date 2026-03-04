import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
      .background(Color.demoBackground)
    }
    .background(Color.demoBackground)
    .task {
      viewModel.send(.onAppearedPage)
    }
    .onDisappear { viewModel.send(.onDisappearedPage) }
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

      HStack(spacing: 10) {
        Button {
          isSelectedLanguageSheet = true
        } label: {
          HStack(spacing: 10) {
            Image(systemName: "globe")
              .font(.system(size: 12))
            Text(viewModel.selectedLangItem?.languageLocal ?? "Language")
              .font(.system(size: 12, weight: .regular))
            Image(systemName: "chevron.down")
              .font(.system(size: 12, weight: .medium))
          }
          .foregroundStyle(.primary)
          .padding(.horizontal, 10)
          .padding(.vertical, 8)
          .background(Color.demoSurface)
          .overlay(
            Capsule()
              .stroke(Color.demoBorder, lineWidth: 2)
          )
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)

        if let lastErrorMessage = viewModel.lastErrorMessage, !lastErrorMessage.isEmpty {
          Text(lastErrorMessage)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.red)
            .lineLimit(2)
            .truncationMode(.tail)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
    .padding(.top, 24)
    .padding(.bottom, 28)
    .background(Color.demoSurface)
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

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<3, id: \.self) { index in
        Circle()
          .fill(Color.demoRealtimeDot)
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

private extension Color {
  static var demoBackground: Color {
#if canImport(UIKit)
    Color(UIColor.systemGray6)
#else
    Color(NSColor.windowBackgroundColor)
#endif
  }

  static var demoSurface: Color {
#if canImport(UIKit)
    Color(UIColor.systemBackground)
#else
    Color(NSColor.controlBackgroundColor)
#endif
  }

  static var demoBorder: Color {
#if canImport(UIKit)
    Color(UIColor.systemGray4)
#else
    Color(NSColor.separatorColor)
#endif
  }

  static var demoRealtimeDot: Color {
#if canImport(UIKit)
    Color(UIColor.systemGray3)
#else
    Color(NSColor.tertiaryLabelColor)
#endif
  }
}
