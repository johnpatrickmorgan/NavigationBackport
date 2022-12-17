import Foundation
import SwiftUI

struct SidebarView: View {
  @Binding var selectedBindingType: BindingType?

  var body: some View {
    if #available(iOS 16.0, *) {
      List(selection: $selectedBindingType) {
        ForEach(BindingType.allCases, id: \.self) { bindingType in
          Text(bindingType.rawValue)
        }
      }
    } else {
      List(selection: $selectedBindingType) {
        ForEach(BindingType.allCases, id: \.self) { bindingType in
          Button {
            selectedBindingType = bindingType
          } label: {
            HStack {
              Text(bindingType.rawValue)
              Spacer()
            }
            .padding()
            .background(bindingType == selectedBindingType ? Color.gray.opacity(0.5) : Color.clear)
            .cornerRadius(10)
            .contentShape(Rectangle())
          }
        }
        .buttonStyle(.plain)
      }
    }
  }
}
