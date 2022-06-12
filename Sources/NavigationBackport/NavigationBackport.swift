import Foundation
import SwiftUI

typealias DestinationBuilder<T> = (T) -> AnyView

enum NavigationBackport {
  public static func calculateSteps<Screen>(from start: [Screen], to end: [Screen], canPushMultiple: Bool) -> [[Screen]] {
    let replacableScreens = end.prefix(start.count)
    let remainingScreens = start.count < end.count ? end.suffix(from: start.count) : []

    if canPushMultiple {
      return [Array(replacableScreens), end]
    }

    var steps = [Array(replacableScreens)]
    var lastStep: [Screen] { steps.last! }

    for screen in remainingScreens {
      steps.append(lastStep + [screen])
    }

    return steps
  }
}
