import Foundation
import SwiftUI

class NavigationPathHolder: ObservableObject {
  var path: Binding<[AnyHashable]>

  init(_ path: Binding<[AnyHashable]>) {
    self.path = path
  }
}
