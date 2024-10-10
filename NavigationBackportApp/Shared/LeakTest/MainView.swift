import SwiftUI

struct MainView: View {
  @StateObject private var viewModel: MainViewModel

  /// When passing an instance of viewModel through the initializer, there is a problem with memory leaks.
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    VStack {
      Text("Main")
      Text("Count: \(MainViewModel.count)")
    }
    .navigationTitle("Main")
  }
}

final class MainViewModel: ObservableObject {
  static var count = 0

  init() {
    Self.count += 1
  }

  deinit {
    Self.count -= 1
  }
}
