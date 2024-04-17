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

  @available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
  /// Associates a destination view with a bound value for use within a
  /// navigation stack.
  ///
  /// Add this view modifer to a view inside an ``NBNavigationStack`` to describe
  /// the view that the stack displays when presenting a particular kind of data. Programmatically
  /// update the binding to display or remove the view. For example:
  ///
  ///     @State private var colorShown: Color?
  ///
  ///     NBNavigationView {
  ///         List {
  ///             Button("Mint") { colorShown = .mint }
  ///             Button("Pink") { colorShown = .pink }
  ///             Button("Teal") { colorShown = .teal }
  ///         }
  ///         .nbNavigationDestination(item: $colorShown) { color in
  ///             ColorDetail(color: color)
  ///         }
  ///     }
  ///
  /// When the person using the app taps on the Mint button, the mint color
  /// is pushed onto the navigation stack. You can pop the view
  /// by setting `colorShown` back to `nil`.
  ///
  /// You can add more than one navigation destination modifier to the stack
  /// if it needs to present more than one kind of data.
  ///
  /// Do not put a navigation destination modifier inside a "lazy" container,
  /// like ``List`` or ``LazyVStack``. These containers create child views
  /// only when needed to render on screen. Add the navigation destination
  /// modifier outside these containers so that the navigation view can
  /// always see the destination.
  ///
  /// - Parameters:
  ///   - item: A binding to the data presented, or `nil` if nothing is
  ///     currently presented.
  ///   - destination: A view builder that defines a view to display
  ///     when `item` is not `nil`.
  func nbNavigationDestination<D: Hashable, C: View>(item: Binding<D?>, @ViewBuilder destination: @escaping (D) -> C) -> some View {
    nbNavigationDestination(
      isPresented: Binding(
        get: { item.wrappedValue != nil },
        set: { isActive, transaction in
          if !isActive {
            item.transaction(transaction).wrappedValue = nil
          }
        }
      ),
      destination: { ConditionalViewBuilder(data: item, buildView: destination) }
    )
  }
}
