import NavigationBackport
import SwiftUI

struct NavigationBackportLeakView: View {
  @State private var path: [Presentable] = []

  var body: some View {
    NBNavigationStack(path: $path) {
      root.nbNavigationDestination(for: Presentable.self) { presentable in
        presentable
      }
    }
    .onChange(of: path) { print($0.count) }
  }

  private var root: some View {
    VStack {
      Button("main") {
        path.append(Presentable(MainView(viewModel: MainViewModel())))
      }

      Button("profile") {
        path.append(Presentable(ProfileView(viewModel: ProfileViewModel())))
      }
    }
  }
}
