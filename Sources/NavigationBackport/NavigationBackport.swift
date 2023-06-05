import Foundation
import SwiftUI

typealias DestinationBuilder<T> = (T) -> AnyView

enum NavigationBackport {
  /// Calculates the minimal number of steps to update from one stack of screens to another, within the constraints of SwiftUI.
  /// - Parameters:
  ///   - start: The initial state.
  ///   - end: The goal state.
  /// - Returns: A series of state updates from the start to end.
  public static func calculateSteps<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> [[Route<Screen>]] {
    let replacableRoutes = end.prefix(start.count)
    let remainingRoutes = start.count < end.count ? end.suffix(from: start.count) : []

    var steps = [Array(replacableRoutes)]
    var lastStep: [Route<Screen>] { steps.last! }

    for route in remainingRoutes {
      steps.append(lastStep + [route])
    }

    return steps
  }

  static func canSynchronouslyUpdate<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> Bool {
    // If there are less than 3 steps, the transformation can be applied in one update.
    let steps = calculateSteps(from: start, to: end)
    return steps.count < 3
  }
}
