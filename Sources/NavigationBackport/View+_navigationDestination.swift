import SwiftUI

struct PushModifier<Destination: View>: ViewModifier {
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
  func push<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(PushModifier(isActiveBinding: isActive, destination: destination))
  }
}

struct SheetModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination

  func body(content: Content) -> some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      content
        .sheet(
          isPresented: isActiveBinding,
          onDismiss: nil,
          content: {
            destination // TODO: .environmentObject(Navigator<Screen>(allRoutes))
          }
        )
    } else {
      // TODO:
//      let asSheet = next?.route?.style.isSheet ?? false
//      content
//        .background(
//          NavigationLink(destination: next, isActive: pushBinding, label: EmptyView.init)
//            .hidden()
//        )
//        .present(
//          asSheet: asSheet,
//          isPresented: asSheet ? sheetBinding : coverBinding,
//          onDismiss: onDismiss,
//          content: {
//            next?
//              .environmentObject(FlowNavigator<Screen>(allRoutes))
//          }
//        )
    }
  }
}

extension View {
  func sheet<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(SheetModifier(isActiveBinding: isActive, destination: destination))
  }
}

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

struct ShowModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var routeStyle: RouteStyle?
  var destination: Destination

  func body(content: Content) -> some View {
    content
      .push(isActive: routeStyle?.isPush == true ? isActiveBinding : .constant(false), destination: destination)
      .sheet(isActive: routeStyle?.isSheet == true ? isActiveBinding : .constant(false), destination: destination)
      .cover(isActive: routeStyle?.isCover == true ? isActiveBinding : .constant(false), destination: destination)
  }
}

extension View {
  func show<Destination: View>(isActive: Binding<Bool>, routeStyle: RouteStyle?, destination: Destination) -> some View {
    return modifier(ShowModifier(isActiveBinding: isActive, routeStyle: routeStyle, destination: destination))
  }
}

struct EmbedModifier: ViewModifier {
  var embedInNavigationView: Bool
  @Environment(\.useNavigationStack) var useNavigationStack

  func wrapped(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), useNavigationStack == .whenAvailable {
      return AnyView(NavigationStack { content })
        .environment(\.isWithinNavigationStack, true)
    } else {
      return AnyView(NavigationView { content }
        .navigationViewStyle(supportedNavigationViewStyle))
        .environment(\.isWithinNavigationStack, false)
    }
  }

  func body(content: Content) -> some View {
    if embedInNavigationView {
      wrapped(content: content)
    } else {
      content
    }
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
