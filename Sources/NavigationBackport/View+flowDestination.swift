import Foundation
import SwiftUI

public extension View {
  func flowDestination<D: Hashable, C: View>(for dataType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return modifier(DestinationBuilderModifier(typedDestinationBuilder: { AnyView(builder($0)) }))
  }
}

public extension View {
  /// Associates a destination view with a binding that can be used to show
  /// the view within a ``FlowStack``.
  ///
  /// In general, favor binding a path to a flow stack for programmatic
  /// navigation. Add this view modifer to a view inside a ``FlowStack``
  /// to programmatically push a single view onto the stack. This is useful
  /// for building components that can push an associated view. For example,
  /// you can present a `ColorDetail` view for a particular color:
  ///
  ///     @State private var showDetails = false
  ///     var favoriteColor: Color
  ///
  ///     FlowStack {
  ///         VStack {
  ///             Circle()
  ///                 .fill(favoriteColor)
  ///             Button("Show details") {
  ///                 showDetails = true
  ///             }
  ///         }
  ///         .flowDestination(isPresented: $showDetails, style: .sheet) {
  ///             ColorDetail(color: favoriteColor)
  ///         }
  ///         .nbNavigationTitle("My Favorite Color")
  ///     }
  ///
  /// Do not put a navigation destination modifier inside a "lazy" container,
  /// like ``List`` or ``LazyVStack``. These containers create child views
  /// only when needed to render on screen. Add the navigation destination
  /// modifier outside these containers so that the navigation stack can
  /// always see the destination.
  ///
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that indicates whether
  ///     `destination` is currently presented.
  ///   - destination: A view to present.
  func flowDestination<V>(isPresented: Binding<Bool>, style: RouteStyle, @ViewBuilder destination: () -> V) -> some View where V: View {
    let builtDestination = AnyView(destination())
    return modifier(
      LocalDestinationBuilderModifier(
        isPresented: isPresented,
        routeStyle: style,
        builder: { builtDestination }
      )
    )
  }
}
