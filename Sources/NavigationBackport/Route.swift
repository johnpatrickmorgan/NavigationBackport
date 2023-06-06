import Foundation

/// A step in the navigation flow of an app, encompassing a Screen and how it should be shown,
/// e.g. via a push navigation, a sheet or a full-screen cover.
public enum Route<Screen> {
  /// A push navigation. Only valid if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: the screen to be shown.
  case push(Screen)
  
  /// A sheet presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter embedInNavigationView: whether the presented screen should be embedded in a `NavigationView`.
  case sheet(Screen, embedInNavigationView: Bool)
  
  /// A full-screen cover presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter embedInNavigationView: whether the presented screen should be embedded in a `NavigationView`.
  @available(OSX, unavailable, message: "Not available on OS X.")
  case cover(Screen, embedInNavigationView: Bool)
  
  /// The root of the stack. The presentation style is irrelevant as it will not be presented.
  /// - Parameter screen: the screen to be shown.
  public static func root(_ screen: Screen, embedInNavigationView: Bool = false) -> Route {
    return .sheet(screen, embedInNavigationView: embedInNavigationView)
  }
  
  /// The screen to be shown.
  public var screen: Screen {
    get {
      switch self {
      case .push(let screen), .sheet(let screen, _), .cover(let screen, _):
        return screen
      }
    }
    set {
      switch self {
      case .push:
        self = .push(newValue)
      case .sheet(_, let embedInNavigationView):
        self = .sheet(newValue, embedInNavigationView: embedInNavigationView)
        #if os(macOS)
        #else
        case .cover(_, let embedInNavigationView):
          self = .cover(newValue, embedInNavigationView: embedInNavigationView)
      #endif
      }
    }
  }
  
  /// Whether the presented screen should be embedded in a `NavigationView`.
  public var embedInNavigationView: Bool {
    switch self {
    case .push:
      return false
    case .sheet(_, let embedInNavigationView), .cover(_, let embedInNavigationView):
      return embedInNavigationView
    }
  }
  
  /// Whether the route is presented (via a sheet or cover presentation).
  public var isPresented: Bool {
    switch self {
    case .push:
      return false
    case .sheet, .cover:
      return true
    }
  }
  
  public func map<NewScreen>(_ transform: (Screen) -> NewScreen) -> Route<NewScreen> {
    switch self {
    case .push:
      return .push(transform(screen))
    case .sheet(_, let embedInNavigationView):
      return .sheet(transform(screen), embedInNavigationView: embedInNavigationView)
#if os(macOS)
#else
    case .cover(_, let embedInNavigationView):
      return .cover(transform(screen), embedInNavigationView: embedInNavigationView)
#endif
    }
  }
}

extension Route: Equatable where Screen: Equatable {}

extension Route: Codable where Screen: Codable {}

extension Route where Screen: Hashable {
  
  func erased() -> Route<AnyHashable> {
    if let anyHashableSelf = self as? Route<AnyHashable>  {
      return anyHashableSelf
    }
    return self.map { $0 }
  }
}
