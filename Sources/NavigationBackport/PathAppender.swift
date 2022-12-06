import Foundation
import SwiftUI

/// An object that never publishes changes, but allows appending to an NBNavigationStack's path.
class PathAppender: ObservableObject {
  var append: ((AnyHashable) -> Void)?
}
