import Foundation
import SwiftUI

/// Keeps hold of the destination builder closures for a given type or local destination ID.
class DestinationBuilderHolder: ObservableObject {
  static func identifier(for type: Any.Type) -> String {
    String(reflecting: type)
  }

  var builders: [String: (Any) -> AnyView?] = [:]

  init() {
    builders = [:]
  }

  func appendBuilder<T>(_ builder: @escaping (T) -> AnyView) {
    let key = Self.identifier(for: T.self)
    builders[key] = { data in
      if let typedData = data as? T {
        return builder(typedData)
      } else {
        return nil
      }
    }
  }

  func appendLocalBuilder(identifier: LocalDestinationID, _ builder: @escaping () -> AnyView) {
    let key = identifier.rawValue.uuidString
    builders[key] = { _ in builder() }
  }

  func removeLocalBuilder(identifier: LocalDestinationID) {
    let key = identifier.rawValue.uuidString
    builders[key] = nil
  }

  func build<T>(_ typedData: T) -> AnyView {
    let base = (typedData as? AnyHashable)?.base
    let type = type(of: base ?? typedData)
    let key: String
    if let identifier = (base ?? typedData) as? LocalDestinationID {
      key = identifier.rawValue.uuidString
    } else {
      key = Self.identifier(for: type)
    }

    if let builder = builders[key], let output = builder(typedData) {
      return output
    }
    assertionFailure("No view builder found for key \(key)")
    return AnyView(Image(systemName: "exclamationmark.triangle"))
  }
}
