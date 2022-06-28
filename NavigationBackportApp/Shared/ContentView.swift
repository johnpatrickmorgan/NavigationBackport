import NavigationBackport
import SwiftUI

struct EmojiVisualisation: Hashable {
  let emoji: Character
  let count: Int
}

struct NumberList: Hashable {
  let range: Range<Int>
}

struct ContentView: View {
  @State var path = NBNavigationPath()

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
