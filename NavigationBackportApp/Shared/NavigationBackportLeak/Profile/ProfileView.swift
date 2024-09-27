import SwiftUI

struct ProfileView: View {
  @StateObject private var viewModel: ProfileViewModel

  /// When passing an instance of viewModel through the initializer, there is a problem with memory leaks.
  init(viewModel: ProfileViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    Text("Profile")
  }
}
