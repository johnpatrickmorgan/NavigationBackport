import Foundation
import SwiftUI

public extension View {
  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  func nbNavigationDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return modifier(DestinationBuilderModifier(typedDestinationBuilder: { AnyView(builder($0)) }))
  }
}

public extension View {
  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  /// Associates a destination view with a binding that can be used to push
  /// the view onto a ``NBNavigationStack``.
  ///
  /// In general, favor binding a path to a navigation stack for programmatic
  /// navigation. Add this view modifer to a view inside a ``NBNavigationStack``
  /// to programmatically push a single view onto the stack. This is useful
  /// for building components that can push an associated view. For example,
  /// you can present a `ColorDetail` view for a particular color:
  ///
  ///     @State private var showDetails = false
  ///     var favoriteColor: Color
  ///
  ///     NBNavigationStack {
  ///         VStack {
  ///             Circle()
  ///                 .fill(favoriteColor)
  ///             Button("Show details") {
  ///                 showDetails = true
  ///             }
  ///         }
  ///         .nbNavigationDestination(isPresented: $showDetails) {
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
  func nbNavigationDestination<V>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View where V: View {
    let builtDestination = AnyView(destination())
    return modifier(
      LocalDestinationBuilderModifier(
        isPresented: isPresented,
        builder: { builtDestination }
      )
    )
  }
}
