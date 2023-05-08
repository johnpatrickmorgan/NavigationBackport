import SwiftUI

struct NavigationLinkModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination
  @Environment(\.isWithinNavigationStack) var isWithinNavigationStack

  func body(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), isWithinNavigationStack {
      AnyView(
        content
          .navigationDestination(isPresented: isActiveBinding, destination: { destination })
      )
    } else {
      AnyView(
        content
          .background(
            NavigationLink(destination: destination, isActive: isActiveBinding, label: EmptyView.init)
              .hidden()
          )
      )
    }
  }
}

extension View {
  func _navigationDestination<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(NavigationLinkModifier(isActiveBinding: isActive, destination: destination))
  }
}
