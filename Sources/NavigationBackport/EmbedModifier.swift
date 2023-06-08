import SwiftUI

struct EmbedModifier: ViewModifier {
  var embedInNavigationView: Bool
  @Environment(\.useNavigationStack) var useNavigationStack

  func wrapped(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), useNavigationStack == .whenAvailable {
      return AnyView(NavigationStack { content })
        .environment(\.isWithinNavigationStack, true)
    } else {
      return AnyView(NavigationView { content }
        .navigationViewStyle(supportedNavigationViewStyle))
        .environment(\.isWithinNavigationStack, false)
    }
  }

  func body(content: Content) -> some View {
    if embedInNavigationView {
      wrapped(content: content)
    } else {
      content
    }
  }
}

/// There are spurious state updates when using the `column` navigation view style, so
/// the navigation view style is forced to `stack` where possible.
private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
