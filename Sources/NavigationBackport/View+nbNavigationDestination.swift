import Foundation
import SwiftUI

public extension View {
  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  func nbNavigationDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return modifier(DestinationBuilderModifier(typedDestinationBuilder: { AnyView(builder($0)) }))
  }
}
