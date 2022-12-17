import SwiftUI

enum SplitViewPane: String {
  case sideBar
  case content
  case detail
}

private struct SplitViewPaneKey: EnvironmentKey {
  static let defaultValue: SplitViewPane? = nil
}

extension EnvironmentValues {
  var splitViewPane: SplitViewPane? {
    get { self[SplitViewPaneKey.self] }
    set { self[SplitViewPaneKey.self] = newValue }
  }
}
