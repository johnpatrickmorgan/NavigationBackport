import Foundation
import NavigationBackport
import SwiftUI

enum BindingType: String, CaseIterable, Hashable {
  case array
  case path
  case noBinding
}

struct SplitDemo: View {
  @State var selectedBindingType: BindingType?

  var body: some View {
    VStack {
      NBNavigationSplitView {
        SidebarView(selectedBindingType: $selectedBindingType)
      } detail: {
        if selectedBindingType == .path {
          NBNavigationPathView()
        } else if selectedBindingType == .array {
          ArrayBindingView()
        } else if selectedBindingType == .noBinding {
          NoBindingView()
        } else {
          Text("Select a binding type").foregroundColor(Color.gray)
        }
      }
    }
  }
}
