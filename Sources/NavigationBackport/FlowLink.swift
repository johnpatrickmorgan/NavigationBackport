import Foundation
import SwiftUI

/// When value is non-nil, shows the destination associated with its type.
public struct FlowLink<P: Hashable, Label: View>: View {
  var value: Route<P>?
  var label: Label

  @EnvironmentObject var routeAppender: RouteAppender

  public init(value: Route<P>?, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
  }

  public var body: some View {
    // TODO: Ensure this button is styled more like a NavigationLink within a List.
    // See: https://gist.github.com/tgrapperon/034069d6116ff69b6240265132fd9ef7
    Button(
      action: {
        guard let value = value else { return }
        routeAppender.append?(value.erased())
      },
      label: { label }
    )
  }
}

public extension FlowLink where Label == Text {
  init(_ titleKey: LocalizedStringKey, value: Route<P>?) {
    self.init(value: value) { Text(titleKey) }
  }

  init<S>(_ title: S, value: Route<P>?) where S: StringProtocol {
    self.init(value: value) { Text(title) }
  }

  init<S>(_ title: S, value: P?, style: RouteStyle) where S: StringProtocol {
    self.init(value: value.map { Route(screen: $0, style: style) }) { Text(title) }
  }

  init(_ titleKey: LocalizedStringKey, value: P?, style: RouteStyle) {
    self.init(value: value.map { Route(screen: $0, style: style) }) { Text(titleKey) }
  }
}
