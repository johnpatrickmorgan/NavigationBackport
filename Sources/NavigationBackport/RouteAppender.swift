import Foundation
import SwiftUI

/// An object that never publishes changes, but allows appending to an FlowStack's path.
class RouteAppender: ObservableObject {
  var append: ((Route<AnyHashable>) -> Void)?
}
