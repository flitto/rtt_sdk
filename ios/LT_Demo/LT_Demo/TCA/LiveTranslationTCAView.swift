import ComposableArchitecture
import LiveTranslationSDK
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct LiveTranslationTCAView: View {
  @Bindable var store: StoreOf<LiveTranslationFeature>

  @State private var isNearBottom: Bool = true
  private let bottomAnchorID = "tca-chat-bottom-anchor"

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollViewReader { scrollProxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 28) {
            ForEach(store.chatList) { item in
              ChatRowView(item: item)
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
        .onChange(of: store.chatList.last?.id) { oldValue, newValue in
          guard newValue != nil else { return }
          guard isNearBottom || oldValue == nil else { return }
          scrollToBottom(using: scrollProxy, animated: oldValue != nil)
        }
      }
      .background(Color.tcaDemoBackground)
    }
    .background(Color.tcaDemoBackground)
    .task { store.send(.onAppear) }
    .onDisappear { store.send(.onDisappear) }
    .sheet(
      isPresented: Binding(
        get: { store.isLanguageSheetPresented },
        set: { if !$0 { store.send(.languageSheetDismissed) } }
      )
    ) {
      SelectLanguageSheet(
        languageList: store.supportLanguages,
        selectedLanguageAction: { item in
          store.send(.languageSelected(item))
        }
      )
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(spacing: 12) {
        Text(store.roomTitle ?? "Loading...")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.primary)
          .lineLimit(1)

        Spacer(minLength: 0)

        Button(action: { store.send(.refresh) }) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(.primary)
            .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
      }

      HStack(spacing: 10) {
        Button {
          store.send(.languageButtonTapped)
        } label: {
          HStack(spacing: 10) {
            Image(systemName: "globe")
              .font(.system(size: 12))
            Text(store.selectedLanguage?.languageLocal ?? "Language")
              .font(.system(size: 12, weight: .regular))
            Image(systemName: "chevron.down")
              .font(.system(size: 12, weight: .medium))
          }
          .foregroundStyle(.primary)
          .padding(.horizontal, 10)
          .padding(.vertical, 8)
          .background(Color.tcaDemoSurface)
          .overlay(
            Capsule()
              .stroke(Color.tcaDemoBorder, lineWidth: 2)
          )
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)

        if let error = store.lastErrorMessage, !error.isEmpty {
          Text(error)
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
    .background(Color.tcaDemoSurface)
    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
  }

  // MARK: - Helpers

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

// MARK: - Colors

private extension Color {
  static var tcaDemoBackground: Color {
#if canImport(UIKit)
    Color(UIColor.systemGray6)
#else
    Color(NSColor.windowBackgroundColor)
#endif
  }

  static var tcaDemoSurface: Color {
#if canImport(UIKit)
    Color(UIColor.systemBackground)
#else
    Color(NSColor.controlBackgroundColor)
#endif
  }

  static var tcaDemoBorder: Color {
#if canImport(UIKit)
    Color(UIColor.systemGray4)
#else
    Color(NSColor.separatorColor)
#endif
  }
}

// MARK: - Preview

#Preview {
  LiveTranslationTCAView(
    store: Store(initialState: LiveTranslationFeature.State()) {
      LiveTranslationFeature()
    } withDependencies: {
      $0.liveTranslation = .testValue
    }
  )
}
