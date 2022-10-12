import Combine
import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationLinkViewModifier<P: Hashable>: ViewModifier {
  @Binding var value: P?

  @EnvironmentObject var pathHolder: NavigationPathHolder

  public func body(content: Content) -> some View {
    content
      .onChange(of: Just(value)) { _ in
          guard let value = value else { return }
          pathHolder.path.wrappedValue.append(value)
      }
  }
}

public extension View {
  func nbNavigationLink<P: Hashable>(value: Binding<P?>) -> some View {
    modifier(NBNavigationLinkViewModifier(value: value))
  }
}
