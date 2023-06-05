import SwiftUI

/// A navigator to use when the `NBNavigationStack` is initialized with a `NBNavigationPath` binding or no binding.`
public typealias PathNavigator = Navigator<AnyHashable>

/// An object available via the environment that gives access to the current path.
@MainActor
public class Navigator<Screen>: ObservableObject {
  let routesBinding: Binding<[Route<Screen>]>

  /// The current navigation path.
  public var routes: [Route<Screen>] {
    get { routesBinding.wrappedValue }
    set { routesBinding.wrappedValue = newValue }
  }

  init(_ routesBinding: Binding<[Route<Screen>]>) {
    self.routesBinding = routesBinding
  }
}
