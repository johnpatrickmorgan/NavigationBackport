import Foundation

/// Various utilities for pushing and popping.
public extension Array where Element: RouteProtocol {
  
  mutating func presentSheet(_ screen: Element.Screen, embedInNavigationView: Bool) {
    append(.sheet(screen, embedInNavigationView: embedInNavigationView))
  }
  
  /// Pushes a new screen.
  /// - Parameter screen: The screen to push.
  mutating func push(_ screen: Element.Screen) {
    append(.push(screen))
  }

  /// Pops a given number of screens off the stack.
  /// - Parameter count: The number of screens to pop. Defaults to 1.
  mutating func pop(_ count: Int = 1) {
    assert(
      self.count - count >= 0,
      "Can't pop\(count == 1 ? "" : " \(count) screens") - the screen count is \(self.count)"
    )
    assert(
      count >= 0,
      "Can't pop \(count) screens - count must be positive"
    )
    guard self.count - count >= 0, count >= 0 else { return }
    removeLast(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index.
  /// - Parameter index: The index that should become the Array's endIndex.
  mutating func popTo(index: Int) {
    let popCount = count - 1 - index
    pop(popCount)
  }

  /// Pops to the root screen. The resulting screen count will be 0.
  mutating func popToRoot() {
    // Popping to index -1 ensures the resulting array is empty.
    popTo(index: -1)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (Element) -> Bool) -> Bool {
    guard let index = lastIndex(where: condition) else {
      return false
    }
    popTo(index: index)
    return true
  }
}

public extension Array where Element: RouteProtocol, Element.Screen: Equatable {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: Element.Screen) -> Bool {
    popTo(where: { $0.screen == screen })
  }
}

public extension Array where Element: RouteProtocol, Element.Screen: Identifiable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(id: Element.Screen.ID) -> Bool {
    popTo(where: { $0.screen.id == id })
  }
}
