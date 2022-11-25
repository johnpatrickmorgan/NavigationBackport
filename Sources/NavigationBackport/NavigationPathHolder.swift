import Foundation
import SwiftUI

class NavigationPathHolder: ObservableObject {
  @Published var path: [AnyHashable] = []
}
