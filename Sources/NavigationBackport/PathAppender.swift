import Foundation
import SwiftUI

class PathAppender: ObservableObject {
  var append: ((AnyHashable) -> Void)?
}
