import Foundation
import SwiftUI

class NavigationPathHolder: ObservableObject {
  var path: Binding<[Any]>

  init(_ path: Binding<[Any]>) {
    self.path = path
  }
}
