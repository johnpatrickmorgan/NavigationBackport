import Foundation
import SwiftUI

/// Uniquely identifies an instance of a local destination builder.
struct LocalDestinationID: RawRepresentable, Hashable {
  let rawValue: UUID
}

/// Persistent object to hold the local destination ID and remove it when the destination builder is removed.
class LocalDestinationIDHolder: ObservableObject {
  let id = LocalDestinationID(rawValue: UUID())
  weak var destinationBuilder: DestinationBuilderHolder?

  func setDestinationBuilder(_ builder: DestinationBuilderHolder) {
    destinationBuilder = builder
  }

  deinit {
    // On iOS 15, there are some extraneous re-renders after LocalDestinationBuilderModifier is removed from
    // the view tree. Dispatching async allows those re-renders to succeed before removing the local builder.
    DispatchQueue.main.async { [destinationBuilder, id] in
      destinationBuilder?.removeLocalBuilder(identifier: id)
    }
  }
}

/// Modifier that appends a local destination builder and ensures the Bool binding is observed and updated.
struct LocalDestinationBuilderModifier: ViewModifier {
  let isPresented: Binding<Bool>
  let builder: () -> AnyView

  @StateObject var destinationID = LocalDestinationIDHolder()
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder
  @EnvironmentObject var pathHolder: NavigationPathHolder
  @Environment(\.isWithinNavigationStack) var isWithinNavigationStack

  func body(content: Content) -> some View {
    if isWithinNavigationStack {
      if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *) {
        content.navigationDestination(isPresented: isPresented, destination: builder)
      } else {
        fatalError("isWithinNavigationStack shouldn't ever be true on platforms that don't support it")
      }
    } else {
      let _ = destinationBuilder.appendLocalBuilder(identifier: destinationID.id, builder)
      let _ = destinationID.setDestinationBuilder(destinationBuilder)

      content
        .environmentObject(destinationBuilder)
        .onChange(of: pathHolder.path) { _ in
          if isPresented.wrappedValue {
            if !pathHolder.path.contains(where: { ($0 as? LocalDestinationID) == destinationID.id }) {
              isPresented.wrappedValue = false
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
}
