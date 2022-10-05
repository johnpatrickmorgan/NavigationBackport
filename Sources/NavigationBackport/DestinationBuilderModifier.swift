import Foundation
import SwiftUI

struct DestinationBuilderModifier<TypedData>: ViewModifier {
  let typedDestinationBuilder: DestinationBuilder<TypedData>

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  func body(content: Content) -> some View {
    destinationBuilder.appendBuilder(typedDestinationBuilder)
    
    return content
      .environmentObject(destinationBuilder)
  }
}
