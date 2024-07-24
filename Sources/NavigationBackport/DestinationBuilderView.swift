import Foundation
import SwiftUI

/// Builds a view from the given Data, using the destination builder environment object.
struct DestinationBuilderView<Data: Hashable>: View {
  let data: Data

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  var body: some View {
    DataDependentView(data: data, content: { destinationBuilder.build(data) }).equatable()
  }
}

struct DataDependentView<Content: View>: View, Equatable {
  static func ==(lhs: DataDependentView, rhs: DataDependentView) -> Bool {
    return lhs.data == rhs.data
  }
  
  let data: AnyHashable
  let content: () -> Content
  
  var body: some View {
    content()
  }
}
