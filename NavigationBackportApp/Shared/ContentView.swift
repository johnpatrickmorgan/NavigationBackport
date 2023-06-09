import NavigationBackport
import SwiftUI

struct EmojiVisualisation: Hashable, Codable {
  let emoji: String
  let count: Int

  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}

struct NumberList: Hashable, Codable {
  let range: Range<Int>
}

class ClassDestination {
  let data: String

  init(data: String) {
    self.data = data
  }
}

extension ClassDestination: Hashable {
  static func == (lhs: ClassDestination, rhs: ClassDestination) -> Bool {
    lhs.data == rhs.data
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
}

class SampleClassDestination: ClassDestination {
  init() { super.init(data: "Sample data") }
}

struct ContentView: View {
  enum Tab: Hashable {
    case flowPath
    case arrayBinding
    case noBinding
    case viewModel
  }

  @State var selectedTab: Tab = .flowPath

  var body: some View {
    TabView(selection: $selectedTab) {
      FlowPathView()
        .tabItem { Text("FlowPath") }
        .tag(Tab.flowPath)
      ArrayBindingView()
        .tabItem { Text("ArrayBinding") }
        .tag(Tab.arrayBinding)
      NoBindingView()
        .tabItem { Text("NoBinding") }
        .tag(Tab.noBinding)
      NumberVMFlow(viewModel: .init(initialNumber: 64))
        .tabItem { Text("ViewModel") }
        .tag(Tab.viewModel)
    }
    .onOpenURL { url in
      guard let deeplink = Deeplink(url: url) else { return }
      follow(deeplink)
    }
  }

  private func follow(_ deeplink: Deeplink) {
    // Test deeplinks from CLI with, e.g.:
    // `xcrun simctl openurl booted flowstacksapp://numbers/42/13`
    switch deeplink {
    case .viewModelTab:
      selectedTab = .viewModel
    }
  }
}
