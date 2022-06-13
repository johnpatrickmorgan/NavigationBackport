import Foundation
import SwiftUI

struct Node<Screen>: View {
  let allScreens: Binding<[Screen]>
  let screen: Screen?
  let index: Int

  @EnvironmentObject var pathHolder: NavigationPathHolder
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  init(allScreens: Binding<[Screen]>, index: Int) {
    self.allScreens = allScreens
    screen = allScreens.wrappedValue[safe: index]
    self.index = index
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
      get: { allScreens.wrappedValue.count != index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allScreens.wrappedValue.count > index + 1 else { return }
        allScreens.wrappedValue = Array(allScreens.wrappedValue.prefix(index + 1))
      }
    )
  }

  var next: some View {
    Node(allScreens: allScreens, index: index + 1)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
  }

  var body: some View {
    DestinationBuilderView(data: allScreens.wrappedValue[safe: index] ?? screen)
      .background(
        NavigationLink(destination: next, isActive: isActiveBinding, label: EmptyView.init)
          .hidden()
      )
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
