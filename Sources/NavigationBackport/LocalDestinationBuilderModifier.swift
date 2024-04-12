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

  func body(content: Content) -> some View {
    destinationBuilder.appendLocalBuilder(identifier: destinationID.id, builder)
    destinationID.destinationBuilder = destinationBuilder

    return content
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

/// Modifier that appends a local destination builder and ensures the Optional Hashable binding is observed and updated.
struct LocalDestinationBuilderForItemModifier<D: Hashable>: ViewModifier {
  let item: Binding<D?>
  let builder: () -> AnyView

  @StateObject var destinationID = LocalDestinationIDHolder()
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder
  @EnvironmentObject var pathHolder: NavigationPathHolder

  func body(content: Content) -> some View {
    destinationBuilder.appendLocalBuilder(identifier: destinationID.id, builder)
    destinationID.destinationBuilder = destinationBuilder

    return content
      .environmentObject(destinationBuilder)
      .onChange(of: pathHolder.path) { _ in
        if item.wrappedValue != nil {
          if !pathHolder.path.contains(where: { ($0 as? LocalDestinationID) == destinationID.id }) {
            item.wrappedValue = nil
          }
        }
      }
      .onChange(of: item.wrappedValue) { [oldValue = item.wrappedValue] newValue in
        guard newValue != oldValue else {
          return
        }
        if newValue != nil {
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
