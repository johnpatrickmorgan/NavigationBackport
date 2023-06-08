import SwiftUI

struct CoverModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination

  func body(content: Content) -> some View {
    #if os(macOS) // Covers are unavailable on macOS
      content
        .sheet(
          isPresented: isActiveBinding,
          onDismiss: nil,
          content: {
            destination // TODO: .environmentObject(Navigator<Screen>(allRoutes))
          }
        )
    #else
      if #available(iOS 14.0, tvOS 14.0, macOS 99.9, *) {
        content
          .fullScreenCover(
            isPresented: isActiveBinding,
            onDismiss: nil,
            content: {
              destination // TODO: .environmentObject(Navigator<Screen>(allRoutes))
            }
          )
      } else { // Covers are unavailable on prior versions
        content
          .sheet(
            isPresented: isActiveBinding,
            onDismiss: nil,
            content: {
              destination // TODO: .environmentObject(Navigator<Screen>(allRoutes))
            }
          )
      }
    #endif
  }
}

extension View {
  func cover<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(CoverModifier(isActiveBinding: isActive, destination: destination))
  }
}

/// There are spurious state updates when using the `column` navigation view style, so
/// the navigation view style is forced to `stack` where possible.
private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
