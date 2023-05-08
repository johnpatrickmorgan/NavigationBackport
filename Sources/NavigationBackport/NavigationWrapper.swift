import SwiftUI

struct NavigationWrapper<Content: View>: View {
  var content: Content
  @Environment(\.useNavigationStack) var useNavigationStack

  var body: some View {
      if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), useNavigationStack == .whenAvailable {
      return AnyView(NavigationStack { content })
        .environment(\.isWithinNavigationStack, true)
    } else {
      return AnyView(NavigationView { content }
        .navigationViewStyle(supportedNavigationViewStyle))
        .environment(\.isWithinNavigationStack, false)
    }
  }

  init(content: () -> Content) {
    self.content = content()
  }
}

public enum UseNavigationStackPolicy {
  case whenAvailable
  case never
}

private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
