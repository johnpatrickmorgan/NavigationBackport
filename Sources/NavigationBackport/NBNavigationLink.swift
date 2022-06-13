import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationLink<P: Hashable, Label: View>: View {
  var value: P?
  var label: Label

  @EnvironmentObject var pathHolder: NavigationPathHolder

  public init(value: P?, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
  }

  public var body: some View {
    //        if #available(iOS 16, *) {
    //            NavigationLink(value: value, label: label)
    //        } else {

    //        Button(
    //            action: {
    //                guard let value = value else { return }
    //                pathHolder.path.wrappedValue.append(value)
    //            },
    //            label: { label }
    //        )

    NavigationLink(isActive: .constant(false), destination: { EmptyView() }, label: { label })
      .simultaneousGesture(TapGesture().onEnded {
        guard let value = value else { return }
        pathHolder.path.wrappedValue.append(value)
      })
    //        }
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
