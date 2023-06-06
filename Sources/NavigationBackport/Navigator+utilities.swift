// import Foundation
//
// public extension Navigator {
//  /// Whether the Array of Routes is able to push new screens. If it is not possible to determine,
//  /// `nil` will be returned, e.g. if there is no `NavigationView` in this routes stack but it's possible
//  /// it has been pushed onto a parent coordinator with a `NavigationView`.
//  var canPush: Bool? {
//    routes.canPush
//  }
//
//  /// Pushes a new screen via a push navigation.
//  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
//  /// - Parameter screen: The screen to push.
//  mutating func push(_ screen: Screen) {
//    routes.push(screen)
//  }
//
//  /// Presents a new screen via a sheet presentation.
//  /// - Parameter screen: The screen to push.
//  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
//  mutating func presentSheet(_ screen: Screen, embedInNavigationView: Bool = false) {
//    routes.presentSheet(screen, embedInNavigationView: embedInNavigationView)
//  }
//
//  #if os(macOS)
//  #else
//    /// Presents a new screen via a full-screen cover presentation.
//    /// - Parameter screen: The screen to push.
//    /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
//    @available(OSX, unavailable, message: "Not available on OS X.")
//    mutating func presentCover(_ screen: Screen, embedInNavigationView: Bool = false) {
//      routes.presentCover(screen, embedInNavigationView: embedInNavigationView)
//    }
//  #endif
// }
//
//// MARK: - Go back
//
// public extension Array where Element: RouteProtocol {
//  /// Goes back a given number of screens off the stack
//  /// - Parameter count: The number of screens to go back. Defaults to 1.
//  mutating func goBack(_ count: Int = 1) {
//    assert(
//      self.count - count >= 0,
//      "Can't go back\(count == 1 ? "" : " \(count) screens") - the screen count is \(self.count)"
//    )
//    assert(
//      count >= 0,
//      "Can't go back \(count) screens - count must be positive"
//    )
//    guard self.count - count >= 0, count >= 0 else { return }
//    removeLast(count)
//  }
//
//  /// Goes back to a given index in the array of screens. The resulting array's count
//  /// will be equal to index.
//  /// - Parameter index: The index that should become top of the stack, e.g. 0 for the root screen.
//  mutating func goBackTo(index: Int) {
//    goBack(count - index)
//  }
//
//  /// Goes back to the root screen (index 0). The resulting array's count will be 0.
//  mutating func goBackToRoot() {
//    guard count > 1 else { return }
//    goBackTo(index: 0)
//  }
//
//  /// Goes back to the topmost (most recently shown) screen in the stack
//  /// that satisfies the given condition. If no screens satisfy the condition,
//  /// the screens array will be unchanged.
//  /// - Parameter condition: The predicate indicating which screen to go back to.
//  /// - Returns: A `Bool` indicating whether a screen was found.
//  @discardableResult
//  mutating func goBackTo(where condition: (Element) -> Bool) -> Bool {
//    guard let index = lastIndex(where: condition) else {
//      return false
//    }
//    goBackTo(index: index)
//    return true
//  }
//
//  /// Goes back to the topmost (most recently shown) screen in the stack
//  /// that satisfies the given condition. If no screens satisfy the condition,
//  /// the screens array will be unchanged.
//  /// - Parameter condition: The predicate indicating which screen to go back to.
//  /// - Returns: A `Bool` indicating whether a screen was found.
//  @discardableResult
//  mutating func goBackTo(where condition: (Screen) -> Bool) -> Bool {
//    return goBackTo(where: { condition($0.screen) })
//  }
// }
//
// public extension Array where Element: RouteProtocol, Screen: Equatable {
//  /// Goes back to the topmost (most recently shown) screen in the stack
//  /// equal to the given screen. If no screens are found,
//  /// the screens array will be unchanged.
//  /// - Parameter screen: The predicate indicating which screen to go back to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func goBackTo(_ screen: Screen) -> Bool {
//    goBackTo(where: { $0.screen == screen })
//  }
// }
//
// public extension Array where Element: RouteProtocol, Screen: Identifiable {
//  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
//  /// with the given ID. If no screens are found, the screens array will be unchanged.
//  /// - Parameter id: The id of the screen to goBack to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func goBackTo(id: Screen.ID) -> Bool {
//    goBackTo(where: { $0.screen.id == id })
//  }
//
//  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
//  /// matching the given screen. If no screens are found, the screens array
//  /// will be unchanged.
//  /// - Parameter screen: The screen to goBack to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func goBackTo(_ screen: Screen) -> Bool {
//    goBackTo(id: screen.id)
//  }
// }
//
///// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
// public extension Array where Element: RouteProtocol, Screen: Identifiable & Equatable {
//  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
//  /// matching the given screen. If no screens are found, the screens array
//  /// will be unchanged.
//  /// - Parameter screen: The screen to goBack to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func goBackTo(_ screen: Screen) -> Bool {
//    goBackTo(id: screen.id)
//  }
// }
//
//// MARK: - Pop
//
// public extension Array where Element: RouteProtocol {
//  /// Pops a given number of screens off the stack. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter count: The number of screens to go back. Defaults to 1.
//  mutating func pop(_ count: Int = 1) {
//    assert(count <= self.count)
//    assert(suffix(count).allSatisfy { $0.style == .push })
//    goBack(count)
//  }
//
//  /// Pops to a given index in the array of screens. The resulting screen count
//  /// will be equal to index. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter index: The index that should become top of the stack, e.g. 0 for the root.
//  mutating func popTo(index: Int) {
//    let popCount = count - index
//    pop(popCount)
//  }
//
//  /// Pops to the root screen (index 0). The resulting screen count
//  /// will be 1. Only screens that have been pushed will
//  /// be popped.
//  mutating func popToRoot() {
//    popTo(index: 0)
//  }
//
//  /// Pops all screens in the current navigation stack only, without dismissing any screens.
//  mutating func popToCurrentNavigationRoot() {
//    var index = endIndex - 1
//    while indices.contains(index), !self[index].isPresented, index > 0 {
//      index -= 1
//    }
//    goBackTo(index: index)
//  }
//
//  /// Pops to the topmost (most recently pushed) screen in the stack
//  /// that satisfies the given condition. If no screens satisfy the condition,
//  /// the screens array will be unchanged. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter condition: The predicate indicating which screen to pop to.
//  /// - Returns: A `Bool` indicating whether a screen was found.
//  @discardableResult
//  mutating func popTo(where condition: (Element) -> Bool) -> Bool {
//    guard let index = lastIndex(where: condition) else {
//      return false
//    }
//    popTo(index: index)
//    return true
//  }
//
//  /// Pops to the topmost (most recently pushed) screen in the stack
//  /// that satisfies the given condition. If no screens satisfy the condition,
//  /// the screens array will be unchanged. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter condition: The predicate indicating which screen to pop to.
//  /// - Returns: A `Bool` indicating whether a screen was found.
//  @discardableResult
//  mutating func popTo(where condition: (Screen) -> Bool) -> Bool {
//    return popTo(where: { condition($0.screen) })
//  }
// }
//
// public extension Array where Element: RouteProtocol, Screen: Equatable {
//  /// Pops to the topmost (most recently pushed) screen in the stack
//  /// equal to the given screen. If no screens are found,
//  /// the screens array will be unchanged. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter screen: The predicate indicating which screen to go back to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func popTo(_ screen: Screen) -> Bool {
//    popTo(where: { $0 == screen })
//  }
// }
//
// public extension Array where Element: RouteProtocol, Screen: Identifiable {
//  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
//  /// with the given ID. If no screens are found, the screens array will be unchanged.
//  /// Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter id: The id of the screen to goBack to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func popTo(id: Screen.ID) -> Bool {
//    popTo(where: { $0.id == id })
//  }
//
//  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
//  /// matching the given screen. If no screens are found, the screens array
//  /// will be unchanged. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter screen: The screen to goBack to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func popTo(_ screen: Screen) -> Bool {
//    popTo(id: screen.id)
//  }
// }
//
///// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
// public extension Array where Element: RouteProtocol, Screen: Identifiable & Equatable {
//  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
//  /// matching the given screen. If no screens are found, the screens array
//  /// will be unchanged. Only screens that have been pushed will
//  /// be popped.
//  /// - Parameter screen: The screen to pop to.
//  /// - Returns: A `Bool` indicating whether a matching screen was found.
//  @discardableResult
//  mutating func popTo(_ screen: Screen) -> Bool {
//    popTo(id: screen.id)
//  }
// }
//
//// MARK: - Dismiss
//
// public extension Array where Element: RouteProtocol {
//  /// Dismisses a given number of presentation layers off the stack. Only screens that have been presented will
//  /// be included in the count.
//  /// - Parameter count: The number of presentation layers to go back. Defaults to 1.
//  mutating func dismiss(count: Int = 1) {
//    assert(count >= 0)
//    var index = endIndex - 1
//    var dismissed = 0
//    while dismissed < count, indices.contains(index) {
//      assert(
//        index >= 0,
//        "Can't dismiss\(count == 1 ? "" : " \(count) screens") - the number of presented screens is \(dismissed)"
//      )
//      guard index >= 0 else { return }
//
//      if self[index].isPresented {
//        dismissed += 1
//      }
//      index -= 1
//    }
//    goBackTo(index: index)
//  }
//
//  /// Dismisses all presented sheets and modals, without popping any pushed screens in the bottommost
//  /// presentation layer.
//  mutating func dismissAll() {
//    let count = self.filter { $0.isPresented }.count
//    guard count > 0 else { return }
//    dismiss(count: count)
//  }
// }
import Foundation

public extension Navigator {
  /// Whether the Array of Routes is able to push new screens. If it is not possible to determine,
  /// `nil` will be returned, e.g. if there is no `NavigationView` in this routes stack but it's possible
  /// it has been pushed onto a parent coordinator with a `NavigationView`.
  var canPush: Bool? {
    routes.canPush
  }

  /// Pushes a new screen via a push navigation.
  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: The screen to push.
  func push(_ screen: Screen) {
    routes.push(screen)
  }

  /// Presents a new screen via a sheet presentation.
  /// - Parameter screen: The screen to push.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
  func presentSheet(_ screen: Screen, embedInNavigationView: Bool = false) {
    routes.presentSheet(screen, embedInNavigationView: embedInNavigationView)
  }

  #if os(macOS)
  #else
    /// Presents a new screen via a full-screen cover presentation.
    /// - Parameter screen: The screen to push.
    /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
    @available(OSX, unavailable, message: "Not available on OS X.")
    func presentCover(_ screen: Screen, embedInNavigationView: Bool = false) {
      routes.presentCover(screen, embedInNavigationView: embedInNavigationView)
    }
  #endif
}

// MARK: - Go back

public extension Navigator {
  /// Goes back a given number of screens off the stack
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func goBack(_ count: Int = 1) {
    routes.goBack(count)
  }

  /// Goes back to a given index in the array of screens. The resulting screen count
  /// will be index + 1.
  /// - Parameter index: The index that should become top of the stack.
  func goBackTo(index: Int) {
    routes.goBackTo(index: index)
  }

  /// Goes back to the root screen (index 0). The resulting screen count
  /// will be 1.
  func goBackToRoot() {
    routes.goBackToRoot()
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func goBackTo(where condition: (Route<Screen>) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func goBackTo(where condition: (Screen) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }
}

public extension Navigator where Screen: Equatable {
  /// Goes back to the topmost (most recently shown) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

public extension Navigator where Screen: Identifiable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(id: Screen.ID) -> Bool {
    routes.goBackTo(id: id)
  }

  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension Navigator where Screen: Identifiable & Equatable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

// MARK: - Pop

public extension Navigator {
  /// Pops a given number of screens off the stack. Only screens that have been pushed will
  /// be popped.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func pop(_ count: Int = 1) {
    routes.pop(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index + 1. Only screens that have been pushed will
  /// be popped.
  /// - Parameter index: The index that should become top of the stack.
  func popTo(index: Int) {
    routes.popTo(index: index)
  }

  /// Pops to the root screen (index 0). The resulting screen count
  /// will be 1. Only screens that have been pushed will
  /// be popped.
  func popToRoot() {
    routes.popToRoot()
  }

  /// Pops all screens in the current navigation stack only, without dismissing any screens.
  func popToCurrentNavigationRoot() {
    routes.popToCurrentNavigationRoot()
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func popTo(where condition: (Route<Screen>) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func popTo(where condition: (Screen) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }
}

public extension Navigator where Screen: Equatable {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

public extension Navigator where Screen: Identifiable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// Only screens that have been pushed will
  /// be popped.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(id: Screen.ID) -> Bool {
    routes.popTo(id: id)
  }

  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension Navigator where Screen: Identifiable & Equatable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to pop to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

// MARK: - Dismiss

public extension Navigator {
  /// Dismisses a given number of presentation layers off the stack. Only screens that have been presented will
  /// be included in the count.
  /// - Parameter count: The number of presentation layers to go back. Defaults to 1.
  func dismiss(count: Int = 1) {
    routes.dismiss(count: count)
  }

  /// Dismisses all presented sheets and modals, without popping any pushed screens in the bottommost
  /// presentation layer.
  func dismissAll() {
    routes.dismissAll()
  }
}
