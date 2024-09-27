import SwiftUI

struct MainView: View {
  @StateObject private var viewModel: MainViewModel

  /// When passing an instance of viewModel through the initializer, there is a problem with memory leaks.
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    Text("Main")
  }
}
