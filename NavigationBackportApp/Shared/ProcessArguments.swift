import Foundation
import NavigationBackport

enum ProcessArguments {
  static var navigationStackPolicy: UseNavigationStackPolicy {
    // Allows the policy to be set from UI tests.
    ProcessInfo.processInfo.arguments.contains("USE_NAVIGATIONSTACK") ? .whenAvailable : .never
  }

  static var nonEmptyAtLaunch: Bool {
    // Allows initial path to be set from UI tests.
    ProcessInfo.processInfo.arguments.contains("NON_EMPTY_AT_LAUNCH")
  }
}
