import Foundation
import SwiftUI

public extension View {
  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  func nbNavigationDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return modifier(DestinationBuilderModifier(typedDestinationBuilder: { AnyView(builder($0)) }))
  }
}

public extension View {
  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  func nbNavigationDestination<V>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View where V: View {
    let builtDestination = AnyView(destination())
    return modifier(
      LocalDestinationBuilderModifier(
        isPresented: isPresented,
        builder: { builtDestination }
      )
    )
  }
}
