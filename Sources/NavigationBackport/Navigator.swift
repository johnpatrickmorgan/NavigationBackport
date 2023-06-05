import SwiftUI

/// A navigator to use when the `NBNavigationStack` is initialized with a `NBNavigationPath` binding or no binding.`
public typealias PathNavigator = Navigator<AnyHashable>

/// An object available via the environment that gives access to the current path.
@MainActor
public class Navigator<Screen>: ObservableObject {
  let pathBinding: Binding<[Route<Screen>]>

  /// The current navigation path.
  public var path: [Route<Screen>] {
    get { pathBinding.wrappedValue }
    set { pathBinding.wrappedValue = newValue }
  }

  init(_ pathBinding: Binding<[Route<Screen>]>) {
    self.pathBinding = pathBinding
  }
}
