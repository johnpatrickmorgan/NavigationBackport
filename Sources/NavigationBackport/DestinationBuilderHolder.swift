import Foundation
import SwiftUI

class DestinationBuilderHolder: ObservableObject {
  var builders: [String: (Any) -> AnyView?] = [:]

  init() {
    builders = [:]
  }

  func appendBuilder<T>(_ builder: @escaping (T) -> AnyView) {
    builders["\(T.self)"] = { data in
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

    if let builder = builders["\(type)"], let output = builder(typedData) {
      return output
    }
//        else {
//            for builder in builders.values {
//                if let output = builder(typedData) {
//                    return output
//                }
//            }
//        }
    assertionFailure("No view builder found for type \(type)")
    return AnyView(Image(systemName: "exclamationmark.triangle"))
  }
}
