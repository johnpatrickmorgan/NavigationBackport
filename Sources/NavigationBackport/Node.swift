import Foundation
import SwiftUI

struct Node<Screen: Hashable>: View {
  @Binding var allScreens: [Screen]
  let truncateToIndex: (Int) -> Void
  let index: Int
  let screen: Screen?

  @State var isAppeared = false

  init(allScreens: Binding<[Screen]>, truncateToIndex: @escaping (Int) -> Void, index: Int) {
    _allScreens = allScreens
    self.truncateToIndex = truncateToIndex
    self.index = index
    screen = allScreens.wrappedValue[safe: index]
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
      get: { allScreens.count > index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allScreens.count > index + 1 else { return }
        guard isAppeared else { return }
        truncateToIndex(index + 1)
      }
    )
  }

  var next: some View {
    Node(allScreens: $allScreens, truncateToIndex: truncateToIndex, index: index + 1)
  }

  var body: some View {
    if let screen = allScreens[safe: index] ?? screen {
      DestinationBuilderView(data: screen)
        ._navigationDestination(isActive: isActiveBinding, destination: next)
        .onAppear { isAppeared = true }
        .onDisappear { isAppeared = false }
    }
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
