import Foundation
import SwiftUI

struct LocalDestinationID: RawRepresentable, Hashable {
  let rawValue: UUID
}

class LocalDestinationIDHolder: ObservableObject {
  let id = LocalDestinationID(rawValue: UUID())
  weak var destinationBuilder: DestinationBuilderHolder?

  deinit {
    destinationBuilder?.removeLocalBuilder(identifier: id)
  }
}

struct LocalDestinationBuilderModifier: ViewModifier {
  let isPresented: Binding<Bool>
  let builder: () -> AnyView

  @StateObject var destinationID = LocalDestinationIDHolder()
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder
  @EnvironmentObject var pathHolder: NavigationPathHolder

  func body(content: Content) -> some View {
    destinationBuilder.appendLocalBuilder(identifier: destinationID.id, builder)
    destinationID.destinationBuilder = destinationBuilder

    return Group {
      content
        .environmentObject(destinationBuilder)
        .onChange(of: pathHolder.path) { _ in
          if isPresented.wrappedValue {
            if !pathHolder.path.contains(where: { ($0 as? LocalDestinationID) == destinationID.id }) {
              isPresented.wrappedValue = false
            }
          }
        }
    }
    .onChange(of: isPresented.wrappedValue) { isPresented in
      if isPresented {
        pathHolder.path.append(destinationID.id)
      } else {
        let index = pathHolder.path.lastIndex(where: { ($0 as? LocalDestinationID) == destinationID.id })
        if let index {
          pathHolder.path.remove(at: index)
        }
      }
    }
  }
}
