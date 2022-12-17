import Foundation
import SwiftUI

struct Router<Screen, RootView: View>: View {
  let rootView: RootView

  @Binding var screens: [AnyHashable]
  @EnvironmentObject var navigator: Navigator<Screen>
  @EnvironmentObject var pathHolder: NavigationPathHolder
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder
  @EnvironmentObject var pathAppender: PathAppender

  init(rootView: RootView, screens: Binding<[AnyHashable]>, screenType: Screen.Type) {
    self.rootView = rootView
    _screens = screens
  }

  var pushedScreens: some View {
    Node<Screen>(allScreens: screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: 0)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
      .environmentObject(navigator)
      .environmentObject(pathAppender)
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

  var body: some View {
    rootView
      .background(
        NavigationLink(destination: pushedScreens, isActive: isActiveBinding, label: EmptyView.init)
          .hidden()
      )
  }
}
