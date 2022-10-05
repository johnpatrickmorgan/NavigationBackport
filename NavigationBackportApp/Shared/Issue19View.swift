import SwiftUI
import NavigationBackport

struct Issue19View: View {
  
  enum Item {
      case one, two
  }
  
  // App will crash on iOS 15.5 if showGreen is initially true and the path is not empty,
  // because the view builder has not yet been added to the environment.
  @State var showGreen = true
  @State var path: [Item] = [.one]

  // For similar reasons, the navigationDestination closure may have a stale version of counter.
  @State var counter = 0

  var body: some View {
    if showGreen {
      Color.green.onAppear {
        showGreen = false
      }
    } else {
      NBNavigationStack(path: $path) {
        VStack(spacing: 10) {
          NBNavigationLink("one", value: Item.one)
          NBNavigationLink("two", value: Item.two)
          Text("\(counter)")
          Button("Increment", action: { counter += 1 })
        }
        .nbNavigationDestination(for: Item.self) { item in
          Text("Detail \(String(describing: item)) \(counter)").navigationTitle(String(describing: item))
        }
        .navigationTitle("Home")
      }
    }
  }
}
