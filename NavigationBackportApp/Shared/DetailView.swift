import Foundation
import SwiftUI
import NavigationBackport

struct DetailView: View {
    
  @Binding var selectedRoute: SidebarRouter?
    
  var body: some View {
    if let selectedRoute = selectedRoute {
      switch selectedRoute {
      case .numbers:
        List {
          ForEach(0..<100) { num in
            NBNavigationLink(value: num) {
              Text(num.description)
            }
          }
        }
        .nbNavigationDestination(for: Int.self) { num in
          Text(num.description)
        }
        .navigationTitle("Numbers")
      case .text:
        Text("Hello World")
          .navigationTitle("Text")
      }
    } else {
      EmptyView()
    }
  }
}
