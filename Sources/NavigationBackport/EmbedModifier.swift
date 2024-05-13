import SwiftUI

/// Embeds a view in a NavigationView or NavigationStack.
struct EmbedModifier: ViewModifier {
  var withNavigation: Bool
  @Environment(\.useNavigationStack) var useNavigationStack

  @ViewBuilder
  func wrapped(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), useNavigationStack == .whenAvailable {
      NavigationStack { content }
        .environment(\.isWithinNavigationStack, true)
    } else {
      NavigationView { content }
        .navigationViewStyle(supportedNavigationViewStyle)
        .environment(\.isWithinNavigationStack, false)
    }
  }

  func body(content: Content) -> some View {
    if withNavigation {
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
