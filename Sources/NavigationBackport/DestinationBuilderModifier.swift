import Foundation
import SwiftUI

/// Modifier for appending a new destination builder.
struct DestinationBuilderModifier<TypedData: Hashable>: ViewModifier {
  let typedDestinationBuilder: DestinationBuilder<TypedData>
  @Environment(\.useNavigationStack) var useNavigationStack

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  func body(content: Content) -> some View {
    destinationBuilder.appendBuilder(typedDestinationBuilder)
    if #available(iOS 16.0, *), useNavigationStack == .whenAvailable {
      return AnyView(
        content
          .navigationDestination(for: TypedData.self, destination: { typedDestinationBuilder($0) })
      )
    } else {
      return AnyView(
        content
          .environmentObject(destinationBuilder)
      )
    }
  }
}
