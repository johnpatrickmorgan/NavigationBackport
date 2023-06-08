import SwiftUI

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
