import Foundation
import SwiftUI

struct DetailView: View {
    
  @Binding var selectedRoute: SidebarRouter?
    
  var body: some View {
    if let selectedRoute = selectedRoute {
      switch selectedRoute {
      case .numbers:
        ArrayBindingView()
      case .text:
        Text("Hello World")
      }
    } else {
      EmptyView()
    }
  }
}
