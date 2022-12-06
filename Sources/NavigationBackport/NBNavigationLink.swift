import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// When value is non-nil, shows the destination associated with its type.
public struct NBNavigationLink<P: Hashable, Label: View>: View {
  var value: P?
  var label: Label

  @EnvironmentObject var pathAppender: PathAppender

  public init(value: P?, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
  }

  public var body: some View {
    // TODO: Ensure this button is styled more like a NavigationLink within a List.
    // See: https://gist.github.com/tgrapperon/034069d6116ff69b6240265132fd9ef7
    Button(
      action: {
        guard let value = value else { return }
        pathAppender.append?(value)
      },
      label: { label }
    )
  }
}

public extension NBNavigationLink where Label == Text {
  init(_ titleKey: LocalizedStringKey, value: P?) {
    self.init(value: value) { Text(titleKey) }
  }

  init<S>(_ title: S, value: P?) where S: StringProtocol {
    self.init(value: value) { Text(title) }
  }
}
