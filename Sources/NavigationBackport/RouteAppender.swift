import Foundation
import SwiftUI

/// An object that never publishes changes, but allows appending to an FlowStack's routes array.
class RouteAppender: ObservableObject {
  var append: ((Route<AnyHashable>) -> Void)?
}
