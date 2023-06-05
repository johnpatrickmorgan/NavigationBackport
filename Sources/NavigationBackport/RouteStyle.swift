import Foundation

/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable {
  case push, sheet(embedInNavigationView: Bool), cover(embedInNavigationView: Bool)

  public var isSheet: Bool {
    switch self {
    case .sheet:
      return true
    case .cover, .push:
      return false
    }
  }

  public var isCover: Bool {
    switch self {
    case .cover:
      return true
    case .sheet, .push:
      return false
    }
  }
}

public extension Route {
  /// Whether the route is pushed, presented as a sheet or presented as a full-screen
  /// cover.
  var style: RouteStyle {
    switch self {
    case .push:
      return .push
    case .sheet(_, let embedInNavigationView):
      return .sheet(embedInNavigationView: embedInNavigationView)
    case .cover(_, let embedInNavigationView):
      return .cover(embedInNavigationView: embedInNavigationView)
    }
  }

  init(screen: Screen, style: RouteStyle) {
    switch style {
    case .push:
      self = .push(screen)
    case .sheet(let embedInNavigationView):
      self = .sheet(screen, embedInNavigationView: embedInNavigationView)
    case .cover(let embedInNavigationView):
      self = .cover(screen, embedInNavigationView: embedInNavigationView)
    }
  }
}
