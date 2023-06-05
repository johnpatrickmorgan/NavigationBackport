import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A type-erased wrapper for an Array of any Hashable types, to be displayed in a `NBNavigationStack`.
public struct NBNavigationPath: Equatable {
  var elements: [Route<AnyHashable>]

  /// The number of screens in the path.
  public var count: Int { elements.count }

  /// WHether the path is empty.
  public var isEmpty: Bool { elements.isEmpty }

  public init(_ elements: [Route<AnyHashable>] = []) {
    self.elements = elements
  }

  public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
    self.init(elements.map { $0 as AnyHashable })
  }

  public mutating func append<V: Hashable>(_ value: Route<V>) {
    elements.append(value.erased())
  }

  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(k)
  }
}
