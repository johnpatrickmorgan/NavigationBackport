import NavigationBackport
import SwiftUI

@main
struct NavigationBackportApp: App {
  var navigationStackPolicy: UseNavigationStackPolicy {
    // Allows the policy to be set from UI tests.
    ProcessInfo.processInfo.arguments.contains("USE_NAVIGATIONSTACK") ? .whenAvailable : .never
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .useNavigationStack(navigationStackPolicy)
    }
  }
}
