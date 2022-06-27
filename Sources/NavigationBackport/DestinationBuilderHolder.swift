import Foundation
import SwiftUI

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

  func build<T>(_ typedData: T) -> AnyView {
    let base = (typedData as? AnyHashable)?.base
    let type = type(of: base ?? typedData)
    let key = Self.identifier(for: type)

    if let builder = builders[key], let output = builder(typedData) {
      return output
    }
    assertionFailure("No view builder found for key \(key)")
    return AnyView(Image(systemName: "exclamationmark.triangle"))
  }
}
