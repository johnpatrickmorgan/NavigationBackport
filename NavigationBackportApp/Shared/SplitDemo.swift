import Foundation
import SwiftUI
import NavigationBackport

struct SplitDemo: View {
    
  @State var selectedRouter: SidebarRouter? = .numbers
    
  var body: some View {
    NBNavigationSplitView {
      SidebarView(selectedRouter: $selectedRouter)
    } detail: {
      DetailView(selectedRoute: $selectedRouter)
    }
  }
}
