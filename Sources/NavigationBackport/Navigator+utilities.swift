import Foundation

public extension Navigator {
  
  func presentSheet(_ screen: Screen, embedInNavigationView: Bool) {
    routes.presentSheet(screen, embedInNavigationView: embedInNavigationView)
  }
  /// Pushes a new screen via a push navigation.
  /// - Parameter screen: The screen to push.
  func push(_ screen: Screen) {
    routes.push(screen)
  }

  /// Pops a given number of screens off the stack.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func pop(_ count: Int = 1) {
    routes.pop(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index.
  /// - Parameter index: The index that should become top of the stack.
  func popTo(index: Int) {
    routes.popTo(index: index)
  }

  /// Pops to the root screen (index 0). The resulting screen count
  /// will be 1.
  func popToRoot() {
    routes.popToRoot()
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func popTo(where condition: (Screen) -> Bool) -> Bool {
    routes.popTo(where: { condition($0.screen) })
  }
}

public extension Navigator where Screen: Equatable {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    return routes.popTo(screen)
  }
}

public extension Navigator where Screen: Identifiable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(id: Screen.ID) -> Bool {
    routes.popTo(id: id)
  }
}

public extension Navigator where Screen == AnyHashable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo<T: Hashable>(_: T.Type) -> Bool {
    // TODO: check
    popTo(where: { $0.base is T })
  }
}
