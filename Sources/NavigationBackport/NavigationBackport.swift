import Foundation
import SwiftUI

typealias DestinationBuilder<T> = (T) -> AnyView

enum NavigationBackport {
  public static func calculateSteps<Screen>(from start: [Screen], to end: [Screen]) -> [[Screen]] {
    let replacableScreens = end.prefix(start.count)
    let remainingScreens = start.count < end.count ? end.suffix(from: start.count) : []

    var steps = [Array(replacableScreens)]
    var lastStep: [Screen] { steps.last! }

    for screen in remainingScreens {
      steps.append(lastStep + [screen])
    }

    return steps
  }
}
