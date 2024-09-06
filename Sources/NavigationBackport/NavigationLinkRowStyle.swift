// Adapted from: https://gist.github.com/tgrapperon/e92d7699b2a6ca8093bdf2cb1abb3376
import SwiftUI

public extension ButtonStyle where Self == NavigationLinkRowStyle {
  /// Experimental approach to mimic the appearance of a `NavigationLink` within a table.
  static var navigationLinkRowStyle: NavigationLinkRowStyle { .init() }
}

/// Mimics the appearance of a `NavigationLink` within a table.
public struct NavigationLinkRowStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    NavigationLink {} label: { configuration.label }
      // HACK: Adding a 'clear' background ensures the tappable area fills the entire space.
      // There may be a better way of achieving this.
      .background(Color.white.opacity(0.0001))
  }
}
