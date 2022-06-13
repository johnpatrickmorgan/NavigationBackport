import Foundation
import SwiftUI

public struct Router<Screen, RootView: View>: View {
  let rootView: RootView

  @Binding var screens: [Screen]
  @EnvironmentObject var pathHolder: NavigationPathHolder
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  public init(rootView: RootView, screens: Binding<[Screen]>) {
    self.rootView = rootView
    _screens = screens
  }

  var pushedScreens: some View {
    Node(allScreens: $screens, index: 0)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
  }

  private var isActiveBinding: Binding<Bool> {
    screens.isEmpty ? .constant(false) : Binding(
      get: { !screens.isEmpty },
      set: { isShowing in
        guard !isShowing else { return }
        guard !screens.isEmpty else { return }
        screens = []
      }
    )
  }

  public var body: some View {
    rootView
      .background(
        NavigationLink(destination: pushedScreens, isActive: isActiveBinding, label: EmptyView.init)
          .hidden()
      )
  }
}
