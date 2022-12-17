import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
  let sideBar: Sidebar
  let content: Content?
  let detail: Detail

  public var body: some View {
    if let content {
      NavigationView {
        sideBar
          .environment(\.splitViewPane, .sideBar)
        content
          .environment(\.splitViewPane, .content)
        detail
          .environment(\.splitViewPane, .detail)
      }
    } else {
      NavigationView {
        sideBar
          .environment(\.splitViewPane, .sideBar)
        detail
          .environment(\.splitViewPane, .detail)
      }
    }
  }

  public init(@ViewBuilder sideBar: () -> Sidebar, @ViewBuilder content: () -> Content, @ViewBuilder detail: () -> Detail) {
    self.sideBar = sideBar()
    self.content = content()
    self.detail = detail()
  }
}

public extension NBNavigationSplitView where Content == EmptyView {
  init(@ViewBuilder sideBar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
    self.sideBar = sideBar()
    self.content = nil
    self.detail = detail()
  }
}
