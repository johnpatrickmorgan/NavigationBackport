import NavigationBackport
import SwiftUI

struct LeakTestView: View {
  @State private var path: [Presentable] = []

  var body: some View {
    NBNavigationStack(path: $path) {
      root.nbNavigationDestination(for: Presentable.self) { presentable in
        presentable
      }
    }
  }

  private var root: some View {
    Button("Main") {
      path.append(Presentable(MainView(viewModel: MainViewModel())))
    }
  }
}
