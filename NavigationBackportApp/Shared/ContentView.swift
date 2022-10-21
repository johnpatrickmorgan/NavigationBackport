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

struct ContentView: View {
  var body: some View {
    TabView {
      NBNavigationPathView()
        .tabItem { Text("NBNavigationPath") }
      ArrayBindingView()
        .tabItem { Text("ArrayBinding") }
      NoBindingView()
        .tabItem { Text("NoBinding") }
    }
  }
}
