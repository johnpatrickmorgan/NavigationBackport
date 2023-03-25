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
    init() { super.init(data: "sample data") }
}

struct ContentView: View {
  var body: some View {
    TabView {
      NBNavigationPathView()
        .tabItem { Text("NBNavigationPath") }
      ArrayBindingView()
        .tabItem { Text("ArrayBinding") }
      NoBindingView()
        .tabItem { Text("NoBinding") }
      Issue33View()
        .tabItem { Text("Issue 33") }
    }
  }
}

struct Issue33View: View {
  @StateObject var viewModel = TabViewModel()

  var body: some View {
    VStack {
      viewModel.currentView
      HStack {
        Button("Home") {
          viewModel.selectedTab = .myHome
        }
        Button("NavStack") {
          viewModel.selectedTab = .navStack
        }
      }
    }
  }
}

enum Tab {
  case myHome, navStack
}

class TabViewModel: ObservableObject {
  @Published var selectedTab: Tab {
    didSet {
      switch selectedTab {
      case .myHome:
        currentView = AnyView(MyHomeView())
      case .navStack:
        currentView = AnyView(ArrayBindingView())
      }
    }
  }

  var currentView: AnyView

  let myHomeView: AnyView
  let navStackView: AnyView

  init() {
    self.myHomeView = AnyView(MyHomeView())
    self.navStackView = AnyView(ArrayBindingView())
    self.selectedTab = .myHome
    self.currentView = myHomeView
  }
}

struct MyHomeView: View {
  @State var isOn = false

  var body: some View {
    VStack {
      Text("MyHomeView")
      Toggle("Toggle", isOn: $isOn)
    }
  }
}
