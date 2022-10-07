import Foundation
import SwiftUI

public class NavigationPathHolder: ObservableObject {
  public var path: Binding<[AnyHashable]>

  public init(_ path: Binding<[AnyHashable]>) {
    self.path = path
  }
}
