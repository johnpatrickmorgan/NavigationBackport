import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationPath {
  var elements: [AnyHashable]

  public var count: Int { elements.count }
  public var isEmpty: Bool { elements.isEmpty }
  public var last: AnyHashable? { elements.last }

  public init(_ elements: [AnyHashable] = []) {
    self.elements = elements
  }

  public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
    self.init(elements.map(AnyHashable.init))
  }

  public mutating func append<V: Hashable>(_ value: V) {
    elements.append(value)
  }

  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(k)
  }
}
