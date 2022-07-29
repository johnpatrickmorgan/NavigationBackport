import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationPath {
  var elements: [Any]

  public var count: Int { elements.count }
  public var isEmpty: Bool { elements.isEmpty }

  public init(_ elements: [Any] = []) {
    self.elements = elements
  }

  @_disfavoredOverload
  public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
    self.init(elements.map { $0 })
  }

  public mutating func append<V: Hashable>(_ value: V) {
    elements.append(value)
  }

  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(k)
  }
}
