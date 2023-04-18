import Foundation
import SwiftUI

struct Router<Screen, RootView: View>: View {
  let rootView: RootView

  @Binding var screens: [Screen]

  init(rootView: RootView, screens: Binding<[Screen]>) {
    self.rootView = rootView
    _screens = screens
  }

  var pushedScreens: some View {
    Node(allScreens: $screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: 0)
  }

  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: { !screens.isEmpty },
      set: { isShowing in
        guard !isShowing else { return }
        guard !screens.isEmpty else { return }
        screens = []
      }
    )
  }

  var body: some View {
    
    if #available(iOS 16.0, *) {
      return AnyView(
        rootView
          .navigationDestination(isPresented: isActiveBinding, destination: { pushedScreens })
      )
    } else {
      return AnyView(
        rootView
          .background(
            NavigationLink(destination: pushedScreens, isActive: isActiveBinding, label: EmptyView.init)
              .hidden()
          )
        )
    }
  }
}
