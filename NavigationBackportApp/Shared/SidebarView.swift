import Foundation
import SwiftUI

enum SidebarRouter: String, Hashable, CaseIterable {
    
  case numbers
  case text
}

struct SidebarView: View {
    
  @Binding var selectedRouter: SidebarRouter?
    
  var body: some View {
    if #available(iOS 16.0, *) {
      List(selection: $selectedRouter) {
        ForEach(SidebarRouter.allCases, id: \.self) { route in
          Text(route.rawValue)
        }
      }
    } else {
      List(selection: $selectedRouter) {
        ForEach(SidebarRouter.allCases, id: \.self) { route in
          Button {
            selectedRouter = route
          } label: {
            HStack {
              Text(route.rawValue)
              Spacer()
            }
            .padding()
            .background(route == selectedRouter ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(10)
            .contentShape(Rectangle())
          }
        }
        .buttonStyle(.plain)
      }
    }
  }
}
