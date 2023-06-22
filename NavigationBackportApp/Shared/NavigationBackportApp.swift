import NavigationBackport
import SwiftUI

@main
struct NavigationBackportApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .nbUseNavigationStack(ProcessArguments.navigationStackPolicy)
    }
  }
}
