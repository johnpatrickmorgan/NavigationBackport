 import Foundation

/// The RouteProtocol is used to restrict the extensions on Array so that they do not
/// pollute autocomplete for Arrays containing other types.
public protocol RouteProtocol {
  associatedtype Screen
  
  static func push(_ screen: Screen) -> Self
  static func sheet(_ screen: Screen, embedInNavigationView: Bool) -> Self
#if os(macOS)
// Full-screen cover unavailable.
#else
  static func cover(_ screen: Screen, embedInNavigationView: Bool) -> Self
#endif
  var screen: Screen { get set }
  var embedInNavigationView: Bool { get }
  var isPresented: Bool { get }
  
  var style: RouteStyle { get }
}

public extension RouteProtocol {
  /// A sheet presentation.
  /// - Parameter screen: the screen to be shown.
  static func sheet(_ screen: Screen) -> Self {
    return sheet(screen, embedInNavigationView: false)
  }
  
#if os(macOS)
// Full-screen cover unavailable.
#else
  /// A full-screen cover presentation.
  /// - Parameter screen: the screen to be shown.
  @available(OSX, unavailable, message: "Not available on OS X.")
  static func cover(_ screen: Screen) -> Self {
    return cover(screen, embedInNavigationView: false)
  }
#endif
  
  /// The root of the stack. The presentation style is irrelevant as it will not be presented.
  /// - Parameter screen: the screen to be shown.
  static func root(_ screen: Screen, embedInNavigationView: Bool = false) -> Self {
    return sheet(screen, embedInNavigationView: embedInNavigationView)
  }
}
  
extension Route: RouteProtocol {}
