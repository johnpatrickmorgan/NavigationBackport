import NavigationBackport
import SwiftUI

@main
struct NavigationBackportApp: App {
  var navigationStackPolicy: UseNavigationStackPolicy {
    return ProcessInfo.processInfo.arguments.contains("USE_NAVIGATIONSTACK") ? .whenAvailable : .never
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .nbUseNavigationStack(navigationStackPolicy)
    }
  }
}
